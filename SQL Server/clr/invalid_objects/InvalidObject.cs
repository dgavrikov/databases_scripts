using System;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.Data;
using Microsoft.SqlServer.Server;
using System.Security.Principal;

public class InvalidObjects
{
    [SqlFunction(DataAccess = DataAccessKind.Read, SystemDataAccess = SystemDataAccessKind.Read, IsDeterministic=false)]
    public static SqlString GetInvalidObjectInfo(int object_id,string dbName, string serverName)
    {
        string ObjectName = null;
        string ObjectType = null;
        const string SetShowPlanOn = "SET SHOWPLAN_XML ON";
        string CheckSQL = "";

        SqlConnectionStringBuilder sb = new SqlConnectionStringBuilder();

        if (string.IsNullOrEmpty(serverName))
        {
            using (SqlConnection sql_conn = new SqlConnection("context connection=true"))
            {
                SqlCommand sql_cmd = sql_conn.CreateCommand();
                sql_cmd.CommandText = "select serverproperty('ComputerNamePhysicalNetBIOS') as ServerName, serverproperty('InstanceName') as InstanceName";
                try
                {
                    sql_conn.Open();
                    using (SqlDataReader dr = sql_cmd.ExecuteReader(CommandBehavior.CloseConnection))
                    {
                        if (dr.Read())
                        {
                            if (dr["InstanceName"] == DBNull.Value)
                                sb.DataSource = Convert.ToString(dr["ServerName"]);
                            else
                                sb.DataSource = string.Format(@"{0}\{1}", Convert.ToString(dr["ServerName"]), Convert.ToString(dr["InstanceName"]));
                            sb.InitialCatalog = dbName;
                            sb.IntegratedSecurity = true;
                            sb.ApplicationName = "CLR Invalid object checker.";
                        }
                        dr.Close();
                    }

                }
                catch (Exception ex)
                {
                    return ex.Message.ToString();
                }
            }
        }
        else
        {
            sb.DataSource = serverName;
            sb.InitialCatalog = dbName;
            sb.IntegratedSecurity = true;
            sb.ApplicationName = "CLR Invalid object checker.";
        }

        using (SqlConnection sql_con = new SqlConnection(sb.ToString()))
        {
            sql_con.Open();
            using (SqlCommand sql_cmd = sql_con.CreateCommand())
            {
                sql_cmd.CommandText = "select quotename(schema_name(schema_id))+'.'+quotename([name]) as fullname, " +
                "rtrim([type]) as [type] from sys.all_objects where object_id = @oid";
                sql_cmd.Parameters.Add("@oid", SqlDbType.Int).Value = object_id;
                try
                {
                    using (SqlDataReader dr = sql_cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            ObjectName = Convert.ToString(dr[0]);
                            ObjectType = Convert.ToString(dr[1]);
                        }
                        else
                            return string.Format("Not found this object_id: {0}", object_id.ToString());
                    }
                }
                catch (Exception ex)
                {
                    return ex.Message;
                }
            }

            switch (ObjectType)
            {
                case "V":
                    CheckSQL = "select * from " + ObjectName;
                    break;
                case "P":
                    CheckSQL = ObjectName;
                    break;
                case "FN":
                    CheckSQL = ObjectName;
                    break;
                case "IF":
                case "TF":
                    using (SqlCommand sql_cmd = new SqlCommand("declare @s varchar(255) set @s = '' " +
                        "select @s = @s+', '+ case type_name(p.user_type_id) " +
                        "when 'uniqueidentifier' then '''00000000-0000-0000-0000-000000000000''' " +
                        "when 'int' then '0' " +
                        "when 'varchar' then '''varchar''' " +
                        "when 'datetime' then '''19000101''' " +
                        "when 'sysname' then '''sysname''' " +
                        "when 'image' then master.sys.fn_varbintohexstr( CAST( 123456 AS BINARY(4))) " +
                        "when 'xml' then '''<root/>''' " +
                        "when 'sql_variant' then '''sql_variant''' " +
                        "when 'money' then '0' " +
                        "when 'decimal' then '0' " +
                        "when 'timestamp' then master.sys.fn_varbintohexstr( @@DBTS) " +
                        "when 'varbinary' then master.sys.fn_varbintohexstr( CAST( 123456 AS BINARY(4))) " +
                        "when 'text' then master.sys.fn_varbintohexstr( CAST( 123456 AS BINARY(4))) " +
                        "when 'smallint' then '0' " +
                        "when 'binary' then master.sys.fn_varbintohexstr( CAST( 123456 AS BINARY(4))) " +
                        "when 'numeric' then '0' " +
                        "when 'tinyint' then '0' " +
                        "when 'nchar' then '''nchar''' " +
                        "when 'float' then '0' " +
                        "when 'char' then '''char''' " +
                        "when 'real' then '0' " +
                        "when 'bigint' then '0' " +
                        "when 'ntext' then master.sys.fn_varbintohexstr( CAST( 123456 AS BINARY(4))) " +
                        "when 'nvarchar' then 'N''nvarchar''' " +
                        "when 'bit' then '0'	end " +
                        "from sys.parameters p where object_id = @oid " +
                        "and default_value is null " +
                        "order by p.parameter_id " +
                        "select @s = case when len(@s)>0 then substring(@s, 3, len(@s)-2) else @s end " +
                        "select @s", sql_con))
                    {
                        sql_cmd.Parameters.Add("@oid", SqlDbType.Int).Value = object_id;

                        using (SqlDataReader dr = sql_cmd.ExecuteReader(CommandBehavior.SingleRow))
                        {
                            if (dr.Read())
                            {
                                CheckSQL = string.Format("select * from {0}({1})", ObjectName, Convert.ToString(dr[0]));
                            }
                            else
                                CheckSQL = string.Format("select * from {0}()", ObjectName);
                        }
                    }
                    break;

                default:
                    return "Not support type('" + ObjectType + "')";

            }

            using (SqlCommand sql_cmd = sql_con.CreateCommand())
            {
                sql_cmd.CommandTimeout = 3600;
                try
                {
                    if (ObjectType != "TF")
                    {
                        sql_cmd.CommandText = SetShowPlanOn;
                        sql_cmd.ExecuteNonQuery();
                    }

                    sql_cmd.CommandText = CheckSQL;
                    sql_cmd.ExecuteNonQuery();
                    return SqlString.Null;
                }
                catch (Exception ex)
                {
                    return ex.Message;
                }
            }
        } // end using SqlConnection
    } // end function
}

