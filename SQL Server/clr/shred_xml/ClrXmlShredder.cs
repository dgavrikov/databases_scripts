using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Xml;
using System.Reflection;
using System.Runtime.InteropServices;

public class ClrXmlShredder
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void ShredXml(SqlXml InputXml,
        [SqlFacet(IsNullable = true), Optional]SqlByte AttributeElementHandling,
        [SqlFacet(IsNullable = true), Optional]SqlByte ConversionHandling, 
        [SqlFacet(MaxSize = 255, IsNullable = true), Optional, DefaultParameterValue(null)]string RootElementName
        )
    {
        //Assume the "AttributeElementHandling" value provided was valid (TODO: error-handling here)
        AttributeElementHandlingPreference attributeElementHandling = AttributeElementHandlingPreference.DetectFromSchema;
        if (!AttributeElementHandling.IsNull)
            attributeElementHandling = (AttributeElementHandlingPreference)AttributeElementHandling.Value;

        //Assume the "ConversionHandling" value provided was valid (TODO: error-handling here)
        TypeConversionHandlingPreference conversionHandling = TypeConversionHandlingPreference.NoConversion;
        if (!ConversionHandling.IsNull)
            conversionHandling = (TypeConversionHandlingPreference)ConversionHandling.Value;

        if (conversionHandling == TypeConversionHandlingPreference.AllConversion)
            throw new Exception("Sorry, the \"All Conversion\" option has not been implemented yet! " +
                "Are you sure you need it? (Standard SQL Server type precedence will auto-convert " +
                "the NVarChar(Max) data to the original corresponding types without issue!)");

        SqlPipe pipe = SqlContext.Pipe;
        using (XmlReader inputReader = InputXml.CreateReader())
        {
            bool requestedRootFound = string.IsNullOrEmpty(RootElementName);
            bool firstElementFound = false;
            List<string> firstRowValues = null;
            SqlMetaData[] outputColumns = null;
            SqlDataRecord outputRecord = null;
            string rowElementName = null;

            while (inputReader.Read())
            {
                if (!requestedRootFound && inputReader.NodeType == XmlNodeType.Element && inputReader.Name.Equals(RootElementName))
                {
                    requestedRootFound = true;
                    continue;
                }

                if (requestedRootFound && inputReader.NodeType == XmlNodeType.EndElement && inputReader.Name.Equals(RootElementName))
                {
                    requestedRootFound = false;
                    continue;
                }

                if (requestedRootFound)
                {
                    if (inputReader.NodeType == XmlNodeType.Element && !firstElementFound)
                    {
                        if (inputReader.Name.Equals("xsd:schema"))
                            outputColumns = BuildColumnsFromSchema(inputReader, ref rowElementName, conversionHandling, ref attributeElementHandling);
                        else
                        {
                            if (attributeElementHandling == AttributeElementHandlingPreference.DetectFromSchema)
                                throw new Exception("Attribute/Element handling preference was set to \"Detect from Schema\", but " +
                                    "no Schema is present in the Xml. Please specify 1 for Attribute-centric Xml or 2 for " +
                                    "Element-centric Xml.");

                            if (conversionHandling == TypeConversionHandlingPreference.BinaryConversionOnly
                                || conversionHandling == TypeConversionHandlingPreference.AllConversion)
                                throw new Exception("Conversion handling preference must be set to 0 (\"no conversion\") because " +
                                    "there is no Schema in the provided Xml.");

                            if (attributeElementHandling == AttributeElementHandlingPreference.Elements)
                                outputColumns = BuildColumnsFromFirstRowElements(inputReader, ref firstRowValues, ref rowElementName);
                            else if (attributeElementHandling == AttributeElementHandlingPreference.Attributes)
                                outputColumns = BuildColumnsFromFirstRowAttributes(inputReader, ref firstRowValues, ref rowElementName);
                            else
                                throw new Exception("invalid option specified for Attribute/Element handling preference.");
                        }

                        outputRecord = new SqlDataRecord(outputColumns);
                        pipe.SendResultsStart(outputRecord);

                        if (firstRowValues != null)
                        {
                            for (int i = 0; i < firstRowValues.Count; i++)
                            {
                                SetRecordValueFromString(outputRecord, outputColumns, i, firstRowValues[i]);
                            }
                            pipe.SendResultsRow(outputRecord);
                        }

                        firstElementFound = true;
                    }
                    else if (inputReader.NodeType == XmlNodeType.Element && inputReader.Name.Equals(rowElementName))
                    {
                        if (attributeElementHandling == AttributeElementHandlingPreference.Elements)
                            FillRecordFromElements(inputReader, outputRecord, outputColumns, rowElementName);
                        else if (attributeElementHandling == AttributeElementHandlingPreference.Attributes)
                            FillRecordFromAttributes(inputReader, outputRecord, outputColumns);

                        pipe.SendResultsRow(outputRecord);
                    }
                }
            }

            if (pipe.IsSendingResults)
                pipe.SendResultsEnd();
        }
    }

    private static SqlMetaData[] BuildColumnsFromSchema(XmlReader inputReader, ref string rowElementName,
        TypeConversionHandlingPreference conversionHandling, ref AttributeElementHandlingPreference attributeElementHandling)
    {
        List<SqlMetaData> tempMetaData = new List<SqlMetaData>();
        bool endFound = false;
        bool columnsRegionFound = false;
        while (!endFound && inputReader.Read())
        {
            if (inputReader.NodeType == XmlNodeType.Element && inputReader.Name.Equals("xsd:sequence"))
            {
                columnsRegionFound = true;
                if (attributeElementHandling == AttributeElementHandlingPreference.Attributes)
                    throw new Exception("Attribute/Element handling set to \"Attribute\", but the schema in the provided Xml specifies " +
                        "an element-based layout!");
                attributeElementHandling = AttributeElementHandlingPreference.Elements;
            }
            else if (!columnsRegionFound && inputReader.NodeType == XmlNodeType.Element && inputReader.Name.Equals("xsd:element"))
            {
                inputReader.MoveToAttribute("name");
                rowElementName = inputReader.ReadContentAsString();
            }
            else if (columnsRegionFound && inputReader.NodeType == XmlNodeType.Element && inputReader.Name.Equals("xsd:element"))
            {
                tempMetaData.Add(GetSqlColumnMetadataFromSchemaEntry(inputReader, conversionHandling));
            }
            else if (inputReader.NodeType == XmlNodeType.Element && inputReader.Name.Equals("xsd:attribute"))
            {
                if (attributeElementHandling == AttributeElementHandlingPreference.DetectFromSchema)
                    attributeElementHandling = AttributeElementHandlingPreference.Attributes;
                else if (attributeElementHandling == AttributeElementHandlingPreference.Elements)
                    throw new Exception("Attribute/Element handling set to \"Elements\", but the schema in the provided Xml specifies " +
                        "an attribute-based layout!");

                if (!columnsRegionFound)
                    columnsRegionFound = true;

                tempMetaData.Add(GetSqlColumnMetadataFromSchemaEntry(inputReader, conversionHandling));
            }
            else if (inputReader.NodeType == XmlNodeType.EndElement && inputReader.Name.Equals("xsd:sequence"))
            {
                columnsRegionFound = false;
            }
            else if (inputReader.NodeType == XmlNodeType.EndElement && inputReader.Name.Equals("xsd:schema"))
            {
                endFound = true;
            }
        }
        return tempMetaData.ToArray();
    }

    private static SqlMetaData GetSqlColumnMetadataFromSchemaEntry(XmlReader inputReader,
        TypeConversionHandlingPreference conversionHandling)
    {
        inputReader.MoveToAttribute("name");
        string columnName = inputReader.ReadContentAsString();
        SqlDbType type = SqlDbType.NVarChar; //default to NVarChar(Max)

        if (conversionHandling == TypeConversionHandlingPreference.BinaryConversionOnly)
        {
            if (inputReader.MoveToAttribute("type"))
            {
                string sqlType = inputReader.ReadContentAsString();
                if (sqlType.Equals("sqltypes:image"))
                    type = SqlDbType.VarBinary;
            }
            else
            {
                //we know there will be a "xsd:simpleType/xsd:restriction", (because there was no 
                // "type" attribute), so pick up the type from there.
                if (inputReader.ReadToFollowing("xsd:simpleType")
                    && inputReader.ReadToFollowing("xsd:restriction")
                    )
                {
                    string sqlBaseType = inputReader.GetAttribute("base");
                    if (sqlBaseType.Equals("sqltypes:varbinary")
                        || sqlBaseType.Equals("sqltypes:binary")
                        )
                        type = SqlDbType.VarBinary;
                }
            }
        }

        return new SqlMetaData(columnName, type, -1);
    }

    private static SqlMetaData[] BuildColumnsFromFirstRowElements(XmlReader inputReader, ref List<string> firstRowValues,
        ref string rowElementName)
    {
        List<SqlMetaData> tempMetaData = new List<SqlMetaData>();
        firstRowValues = new List<string>();
        bool continueSearching = true;
        bool skipRead = false;
        rowElementName = inputReader.Name;

        while (continueSearching && (skipRead || inputReader.Read()))
        {
            skipRead = false;
            if (inputReader.NodeType == XmlNodeType.Element)
            {
                bool valueIsNull = false;
                tempMetaData.Add(new SqlMetaData(inputReader.Name, SqlDbType.NVarChar, -1));
                if (inputReader.HasAttributes
                    && inputReader.MoveToAttribute("nil", "http://www.w3.org/2001/XMLSchema-instance")
                    && inputReader.ReadContentAsString().Equals("true")
                    )
                    valueIsNull = true;

                if (valueIsNull)
                    firstRowValues.Add(null);
                else
                {
                    firstRowValues.Add(inputReader.ReadElementContentAsString());
                    skipRead = true;
                }
            }
            else if (inputReader.NodeType == XmlNodeType.EndElement && inputReader.Name.Equals(rowElementName))
            {
                continueSearching = false;
            }
        }
        return tempMetaData.ToArray();
    }

    private static SqlMetaData[] BuildColumnsFromFirstRowAttributes(XmlReader inputReader, ref List<string> firstRowValues,
        ref string rowElementName)
    {
        List<SqlMetaData> tempMetaData = new List<SqlMetaData>();
        firstRowValues = new List<string>();
        rowElementName = inputReader.Name;

        int attributeCount = inputReader.AttributeCount;
        int currentAttributeID = 0;

        while (currentAttributeID < attributeCount)
        {
            inputReader.MoveToAttribute(currentAttributeID);
            if (!inputReader.Name.Equals("xmlns"))
            {
                tempMetaData.Add(new SqlMetaData(inputReader.Name, SqlDbType.NVarChar, -1));
                firstRowValues.Add(inputReader.ReadContentAsString());
            }
            currentAttributeID++;
        }
        return tempMetaData.ToArray();
    }

    private static void FillRecordFromElements(XmlReader inputReader, SqlDataRecord outputRecord, SqlMetaData[] outputColumns,
        string rowElementName)
    {
        bool continueReading = true;
        bool skipRead = false;
        int expectedColumnID = 0;

        while (continueReading && (skipRead || inputReader.Read()))
        {
            skipRead = false;
            if (inputReader.NodeType == XmlNodeType.Element)
            {
                //collect nulls for any missing columns - if "XSINIL" was not set when calling 
                while (!inputReader.Name.Equals(outputColumns[expectedColumnID].Name))
                {
                    if (expectedColumnID == outputColumns.Length - 1)
                    {
                        //we ran out of columns - thrown an error
                        throw new Exception("Unknown element found! (is it possible you did not specify a schema, did not specify " +
                            "the \"XSINIL\" option, and had a null value in the first row? This would prevent successful column " +
                            "auto-detection...");
                    }
                    outputRecord.SetValue(expectedColumnID, null);
                    expectedColumnID++;
                }


                bool valueIsNull = false;
                if (inputReader.HasAttributes
                    && inputReader.MoveToAttribute("nil", "http://www.w3.org/2001/XMLSchema-instance")
                    && inputReader.ReadContentAsString().Equals("true")
                    )
                    valueIsNull = true;

                if (valueIsNull)
                {
                    outputRecord.SetValue(expectedColumnID, null);
                }
                else
                {
                    SetRecordValueFromString(outputRecord, outputColumns, expectedColumnID, inputReader.ReadElementContentAsString());
                    skipRead = true;
                }
                expectedColumnID++;
            }
            else if (inputReader.NodeType == XmlNodeType.EndElement && inputReader.Name.Equals(rowElementName))
            {
                continueReading = false;
            }
        }

        //set any missing columns at the end to null
        while (expectedColumnID < outputColumns.Length)
        {
            outputRecord.SetValue(expectedColumnID, null);
            expectedColumnID++;
        }
    }

    private static void FillRecordFromAttributes(XmlReader inputReader, SqlDataRecord outputRecord, SqlMetaData[] outputColumns)
    {
        int expectedColumnID = 0;
        int attributeCount = inputReader.AttributeCount;
        int currentAttributeID = 0;

        while (currentAttributeID < attributeCount)
        {
            inputReader.MoveToAttribute(currentAttributeID);
            if (!inputReader.Name.Equals("xmlns"))
            {
                //collect nulls for any missing columns
                while (!inputReader.Name.Equals(outputColumns[expectedColumnID].Name))
                {
                    if (expectedColumnID == outputColumns.Length - 1)
                    {
                        //we ran out of columns - thrown an error
                        throw new Exception("Unknown attribute found! (is it possible you did not specify a schema, and had a null " +
                            "value in the first row? This would prevent successful column auto-detection...)");
                    }
                    outputRecord.SetValue(expectedColumnID, null);
                    expectedColumnID++;
                }

                SetRecordValueFromString(outputRecord, outputColumns, expectedColumnID, inputReader.ReadContentAsString());
                expectedColumnID++;
            }
            currentAttributeID++;
        }

        //set any missing columns at the end to null
        while (expectedColumnID < outputColumns.Length)
        {
            outputRecord.SetValue(expectedColumnID, null);
            expectedColumnID++;
        }
    }

    private static void SetRecordValueFromString(SqlDataRecord outputRecord, SqlMetaData[] columns, int columnID, string valueString)
    {
        if (valueString == null)
            outputRecord.SetValue(columnID, null);
        else
        {
            if (columns[columnID].DbType == DbType.Binary)
            {
                byte[] binaryData = Convert.FromBase64String(valueString);
                outputRecord.SetBytes(columnID, 0, binaryData, 0, binaryData.Length);
            }
            else
            {
                outputRecord.SetSqlString(columnID, new SqlString(valueString));
            }
        }
    }

    public enum AttributeElementHandlingPreference : byte
    {
        DetectFromSchema = 0,
        Attributes = 1,
        Elements = 2
    }

    public enum TypeConversionHandlingPreference : byte
    {
        NoConversion = 0,
        BinaryConversionOnly = 1,
        AllConversion = 2
    }
}
