using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.IO;
using System.IO.Compression;

public class DataCompression
{
    [SqlFunction(IsDeterministic=true,DataAccess=DataAccessKind.None)]
    public static SqlBytes fnCompress(SqlBytes blob)
    {
        if (blob.IsNull)
            return blob;
        
        byte[] blobData = blob.Buffer;

        MemoryStream compressData = new MemoryStream();
        DeflateStream compressor = new DeflateStream(compressData, CompressionMode.Compress, true);

        compressor.Write(blobData, 0, blobData.Length);
        compressor.Flush();
        compressor.Close();
        compressor = null;

        return new SqlBytes(compressData);        
    }

    [SqlFunction(IsDeterministic=true,DataAccess=DataAccessKind.None)]
    public static SqlBytes fnDecompress(SqlBytes compressBlob)
    {
        if (compressBlob.IsNull)
            return compressBlob;

        DeflateStream decompressor = new DeflateStream(compressBlob.Stream, CompressionMode.Decompress, true);        
        int bytesRead = 1;
        int chunkSize = 8192;
        byte[] chunk = new byte[chunkSize];

        MemoryStream decompressData = new MemoryStream();
        try
        {
            while ((bytesRead = decompressor.Read(chunk, 0, chunkSize)) > 0)
            {
                decompressData.Write(chunk, 0, bytesRead);
            }
        }
        finally
        {
            decompressor.Close();
        }
        return new SqlBytes(decompressData);
            
    }
}
