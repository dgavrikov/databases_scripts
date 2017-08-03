ClrXmlShredder - a CLR Stored Procedure for shredding the Xml result of "FOR XML"

Copyright Tao Klerks, June 2011, tao@klerks.biz
Licensed under the modified BSD license (license text below).

--------
Overview
--------

 SQL Server has supported conversion of tabular data into Xml since SQL Server 2000,
with the "FOR XML" clause. For turning Xml data back into tabular resultsets, it
supports "OPENXML" and since 2005 the "nodes()" Xml Function. 

 Both "OPENXML" and "nodes()" require customization / knowledge of the format of the 
Xml data to be "shredded" back into tabular format; this is in contrast to the 
"FOR XML" clause, whose "AUTO" and "RAW" options allow you to generate appropriate 
Xml automatically, without needing to know about / think about the data you are 
converting.

 Because of the "automatic" nature of this "FOR XML" generation, it's tempting to use 
it for diverse purposes in SQL Server:
 * Messaging Payload
 * Log of changed data in arbitrary updates
 * Log of exported data
 * etc

 The main problem with this approach is that it's difficult to change this 
automatically generated Xml back into tabular data. In my searches I've been unable 
to find any simple existing solutions - hence this class, I hope it helps someone!

 This proc will be maintained/enhanced if there's any interest, please check out 
http://architectshack.com/ClrXmlShredder.ashx and/or contact me with any questions.
It is being maintained as a GitHub Gist, feel free to fork and modify of course!
 
-----------
Usage Notes
-----------

ShredXml @InputXml, @AttributeElementHandling, @ConversionHandling

 * @InputXml - the Xml to be returned as a tabular resultset. The assumption is 
that this was created with the FOR XML clause. If not, it will probably still work 
correctly when the "@AttributeElementHandling" is manually set to "Elements" or 
"Attributes", as long as the Xml is "tabular" - as long as it only has 2 levels.

 * @AttributeElementHandling:
   * 0 (default): use schema to determine whether the Xml is element or atribute-based
   * 1: look for attributes
   * 2: look for elements

 * @ConversionHandling:
   * 0 (default): return all columns as NVarChar(Max), with the raw xml value.
   * 1 (requires a schema to be included in the xml): return all columns as 
      NVarChar(Max) EXCEPT binary, varbinary and image columns, which are returned 
      with their (Base64-decoded) binary value in a VarBinary(Max) column.

 * @RootElementName - specify this when you want to start collecting row (and/or
schema data) at some specific element in the provided Xml. This can be used with 
the "FOR XML" ROOT directive, or to work with any arbitrary Xml that contains nested 
tabular data. If the specified element is present multiple times in the provided Xml,
all the instances encountered will be used (and we expect to find the same column
structure!)

 * By default, the type of all output columns is NVarChar(Max). This will work 
automatically with SQL Server's automatic type conversion / type precedence rules for 
all types EXCEPT binary/varbinary/image. You have the option of specifying specific 
typed output just for these binary types (assuming "XMLSCHEMA" was specified in the 
"FOR XML" clause, and we can therefore identify the column types), by setting the 
"@ConversionHandling" parameter identified above. If you want to get a fully typed 
resultset, that could be supported, but the current code does not handle it.

 * Characters in column names that are not valid in Xml Names get auto-escaped by 
the FOR XML clause; the column names that contain these escaped characters are NOT 
automatically converted back to their original forms (but could be, ask if you're 
interested!)

 * Null handling will cause problems if you don't specify a schema AND don't specify 
the "XSINIL" option, AND have a Null value in your first row. (this is because SQL
Server then omits the element entirely, and we use the first data row to determine 
the column structure to be used). To be safe, ALWAYS make sure you specify the 
XMLSCHEMA option and/or the "XSINIL" option in your FOR XML clause!

 * If you want to access the resultset output by this CLR proc from within T-SQL, 
you encounter the same problem as with any stored proc in T-SQL, which is that there
is no equivalent to "SELECT .. INTO ..." for stored procedures. You end up having 2 
general approaches, there are examples of both in the section below:

   1) Declare a table variable or temp table with the appropriate schema, and use 
 "INSERT INTO ... EXEC dbo.ShredXml" to actually put the data into the temp table
 or table variable. This can be a pain for a large table, or if you're not sure 
 about the column datatypes, or if this is for a process that coule run on different
 schemas.

   2) Resort to "Dirty Tricks" to get SQL Server to auto-create a temp table from 
 the stored procedure output resultset. The only good approach I know of here is 
 using "OPENQUERY" or "OPENROWSET", which are options that need to be explicitly 
 enabled at the server level! 

 * Visual Studio's "Deploy" option for SQL Server projects does not support 
optional stored procedure parameters. To make the parameters optional you'll need
to deploy the proc manually, as outlined in the installation instructions below.

------------
Installation
------------

 * Compile this class, or download the DLL directly from 
http://architectshack.com/ClrXmlShredder.ashx

 * Ensure that CLR integration is enabled in sql server:
http://msdn.microsoft.com/en-us/library/ms131048.aspx
 
 * Create the assembly object in the database (using an appropriate path for the DLL!): 
CREATE ASSEMBLY ClrXmlShredder FROM 'c:\ClrXmlShredder.dll' WITH PERMISSION_SET = SAFE
 
 * Create the stored procedure in the database:
CREATE PROCEDURE [dbo].[ShredXml] (
    @InputXml [xml], 
    @AttributeElementHandling [tinyint] = 0,
    @ConversionHandling [tinyint] = 0,
    @RootElementName [nvarchar](255) = null
    )
AS EXTERNAL NAME [ClrXmlShredder].[ClrXmlShredder].[ShredXml]

 * Test: simple examples below

--------
Examples
--------

--Simplest case, using FOR XML RAW
DECLARE @XmlVariable Xml
SET @XmlVariable = (
  SELECT 1 AS FirstColumn, 'One' AS SecondColumn
  FOR XML RAW, XMLSCHEMA 
  )
SELECT @XmlVariable
EXEC ShredXml @XmlVariable
GO

--Output and restore Binary data, using FOR XML with BINARY BASE64
DECLARE @XmlVariable Xml
SET @XmlVariable = (
  SELECT 1 AS FirstColumn, 0x202020 AS SecondColumn
  FOR XML RAW, XMLSCHEMA, BINARY BASE64
  )
SELECT @XmlVariable --note the Base64 string in the Xml
EXEC ShredXml @InputXml = @XmlVariable, @ConversionHandling = 1
GO

--Use the "Root" option to FOR XML, to generate a valid xml document instead of a fragment/nodeset
DECLARE @XmlVariable Xml
SET @XmlVariable = (
  SELECT 1 AS FirstColumn, 0x202020 AS SecondColumn
  FOR XML RAW, XMLSCHEMA, BINARY BASE64, ROOT ('MyVarXml')
  )
SELECT @XmlVariable
EXEC ShredXml @InputXml = @XmlVariable, @ConversionHandling = 1, @RootElementName = 'MyVarXml'
GO

--Consume some random/arbitrary attribute-oriented Xml (as long as it's tabular and has no missing 
-- attributes in the first row!)
DECLARE @XmlVariable Xml
SET @XmlVariable = '<SomeRow FirstColumn="FirstValue" SecondColumn = "" />' 
    + '<SomeRow FirstColumn="SecondValue" SecondColumn="AnotherValue" />'
SELECT @XmlVariable
EXEC ShredXml @InputXml = @XmlVariable, @AttributeElementHandling = 1
GO

--Consume some random/arbitrary element-oriented Xml (as long as it's tabular and has no missing 
-- elements in the first row!)
DECLARE @XmlVariable Xml
SET @XmlVariable = '<SomeRow><FirstColumn>FirstValue</FirstColumn><SecondColumn  /></SomeRow>' 
    + '<SomeRow><FirstColumn>SecondValue</FirstColumn><SecondColumn>AnotherValue</SecondColumn></SomeRow>'
SELECT @XmlVariable
EXEC ShredXml @InputXml = @XmlVariable, @AttributeElementHandling = 2
GO

--Collect Rows from a specific element within some random/arbitrary Xml (as long as it's tabular and has 
-- no missing elements in the first row!)
DECLARE @XmlVariable Xml
SET @XmlVariable = '<DocumentElement>'
    + '<ArbitraryContentElement>'
    + '<SomeRow><FirstColumn>FirstValue</FirstColumn><SecondColumn  /></SomeRow>' 
    + '<SomeRow><FirstColumn>SecondValue</FirstColumn><SecondColumn>AnotherValue</SecondColumn></SomeRow>'
    + '</ArbitraryContentElement>'
    + '</DocumentElement>'
SELECT @XmlVariable
EXEC ShredXml @InputXml = @XmlVariable, @AttributeElementHandling = 2, @RootElementName = 'ArbitraryContentElement'
GO

--Collect Rows from a specific element at multiple locations within some random/arbitrary Xml (as long as it's 
-- tabular and has no missing elements in the first row!)
DECLARE @XmlVariable Xml
SET @XmlVariable = '<DocumentElement>'
    + '<SomeOtherStructure>'
    + '<ArbitraryContentElement><SomeRow FirstColumn="FirstValue" SecondColumn="" /></ArbitraryContentElement>' 
    + '</SomeOtherStructure>'
    + '<SomeOtherStructure>'
    + '<ArbitraryContentElement><SomeRow FirstColumn="SecondValue" SecondColumn="AnotherValue" /></ArbitraryContentElement>'
    + '</SomeOtherStructure>'
    + '</DocumentElement>'
SELECT @XmlVariable
EXEC ShredXml @InputXml = @XmlVariable, @AttributeElementHandling = 1, @RootElementName = 'ArbitraryContentElement'
GO


--INSERT INTO example
DECLARE @TestTable TABLE (OneColumn Int, AnotherColumn NVarChar(10))
DECLARE @XmlVariable Xml
SET @XmlVariable = (
  SELECT 1 AS FirstColumn, 'One' AS SecondColumn
  FOR XML RAW, XMLSCHEMA 
  )
INSERT INTO @TestTable
EXEC ShredXml @XmlVariable, 0, 0
SELECT * FROM @TestTable
GO

------------
--OPENROWSET example for getting an automatically-generated temp table with the contents of the Xml:
------------
--sp_configure 'show advanced options', 1
--reconfigure
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1
--reconfigure
--GO
--sp_configure 'show advanced options', 0
--reconfigure
--GO
SELECT  * 
INTO #TempResultSet
FROM OPENROWSET (
	'SQLOLEDB',
	'Server=(local)\SQLEXPRESS;TRUSTED_CONNECTION=YES;',
	'SET FMTONLY OFF  
DECLARE @XmlVariable Xml
SET @XmlVariable = (
  SELECT 1 AS FirstColumn, ''One'' AS SecondColumn
  FOR XML RAW, XMLSCHEMA 
  )
EXEC MyDBName.dbo.ShredXml @XmlVariable, 0, 0
')
SELECT * FROM #TempResultSet
DROP TABLE #TempResultSet


=======
License
=======

Redistribution and use in source and binary forms, with or without modification, are 
permitted provided that the following conditions are met:

 - Redistributions of source code must retain the above copyright notice, this list of 
conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list 
of conditions and the following disclaimer in the documentation and/or other materials
provided with the distribution.
 - The name of the author may not be used to endorse or promote products derived from 
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY 
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
OF SUCH DAMAGE.

