IF OBJECT_ID(N'msdb.dbo.SmartShrink',N'U') IS NULL
	CREATE TABLE msdb.dbo.SmartShrink(
		spid INT NOT NULL DEFAULT (@@SPID),
		ObjectName NVARCHAR(513) NOT NULL,
		QueryCrtIndex NVARCHAR(MAX) NOT NULL,
		QueryDrpIndex NVARCHAR(MAX) NOT NULL,
		StartCreate DATETIME NULL,
		EndCreate DATETIME NULL,
		StartDrop DATETIME NULL,
		EndDrop DATETIME NULL,		
		CONSTRAINT PK_SmartShrink PRIMARY KEY CLUSTERED (spid,ObjectName)
		);
GO
IF OBJECT_ID(N'msdb.dbo.SmartShrinkParams',N'U') IS NULL
	CREATE TABLE msdb.dbo.SmartShrinkParams(
		spid INT NOT NULL DEFAULT (@@SPID),
		GetIndex TINYINT NOT NULL DEFAULT(0),
		CreateIndex BIT NOT NULL DEFAULT(0),
		ShrinkFile BIT NOT NULL DEFAULT(0),
		DropIndex BIT NOT NULL DEFAULT(0),	
		CONSTRAINT PK_SmartShrinkParams PRIMARY KEY CLUSTERED (spid)
		);
GO
IF OBJECT_ID(N'msdb.dbo.SmartShrinkLog',N'U') IS NULL BEGIN 
	CREATE TABLE msdb.dbo.SmartShrinkLog(
		TimeIns DATETIME2 NOT NULL DEFAULT(SYSDATETIME()),
		MsgText VARCHAR(1000) NOT NULL,
		QueryText VARCHAR(MAX) NULL,
		SPID INT NOT NULL DEFAULT(@@SPID)
		);
	CREATE CLUSTERED INDEX ixSmartShrinkLog
	ON msdb.dbo.SmartShrinkLog(TimeIns,SPID)
END
GO
IF OBJECT_ID ('tempdb..#GetIndex','P') IS NOT NULL
	drop PROCEDURE #GetIndex;
GO
CREATE PROCEDURE #GetIndex(@spid INT,@TableSpace sysname = NULL)
AS 
BEGIN
--  уча обычна¤ 
INSERT INTO msdb.dbo.SmartShrinkLog( MsgText) VALUES('#SmartShrink.#GetData: index get start.');

DELETE FROM msdb.dbo.SmartShrink WHERE spid = @spid;

INSERT INTO msdb.dbo.SmartShrink( ObjectName ,QueryCrtIndex ,QueryDrpIndex )
SELECT 
		QUOTENAME(SCHEMA_NAME(tbl.schema_id))+'.'+QUOTENAME(tbl.name)
	,N'USE '+QUOTENAME(DB_NAME())+';
'+N'CREATE CLUSTERED INDEX [clidxtmp_'+tbl.name+N'] ON '+QUOTENAME(SCHEMA_NAME(tbl.schema_id))+N'.'+QUOTENAME(tbl.name)+ N' ('+col.name+N')'
	,N'USE '+QUOTENAME(DB_NAME())+';
'+N'DROP INDEX [clidxtmp_'+tbl.name+N'] ON '+QUOTENAME(SCHEMA_NAME(tbl.schema_id))+N'.'+QUOTENAME(tbl.name)	
FROM sys.tables tbl
INNER JOIN sys.indexes idx ON idx.object_id = tbl.object_id AND idx.index_id = 0
INNER JOIN sys.columns col ON col.object_id = tbl.object_id AND col.column_id = 1
JOIN sys.data_spaces ds ON ds.data_space_id = idx.data_space_id
inner join sys.filegroups as fg on fg.data_space_id =  ds.data_space_id
WHERE SCHEMA_NAME(tbl.schema_id) NOT IN ('sys') AND ds.type = 'FG' 
AND (fg.name = @TableSpace OR @TableSpace IS NULL);

--  уча секционированна¤
INSERT INTO msdb.dbo.SmartShrink( ObjectName ,QueryCrtIndex ,QueryDrpIndex )
SELECT DISTINCT QUOTENAME(SCHEMA_NAME(tbl.schema_id))+'.'+QUOTENAME(tbl.name)
	,N'USE '+QUOTENAME(DB_NAME())+';
'+N'CREATE CLUSTERED INDEX [clidxtmp_'+tbl.name+N'] ON '+QUOTENAME(SCHEMA_NAME(tbl.schema_id))+N'.'+QUOTENAME(tbl.name)+ N' ('+c.name+N') ON '+ds.name+N' ('+c.name+N')'	
	,N'USE '+QUOTENAME(DB_NAME())+';
'+N'DROP INDEX [clidxtmp_'+tbl.name+N'] ON '+QUOTENAME(SCHEMA_NAME(tbl.schema_id))+N'.'+QUOTENAME(tbl.name)
from  sys.tables          tbl
join  sys.indexes         idx ON(idx.object_id = tbl.object_id 	and idx.index_id = 0)
join  sys.index_columns  ic on(ic.partition_ordinal > 0 and ic.index_id = idx.index_id and ic.object_id = tbl.object_id)
join  sys.columns c on(c.object_id = ic.object_id and c.column_id = ic.column_id)
JOIN sys.data_spaces ds	ON ds.data_space_id = idx.data_space_id
JOIN sys.partitions p ON p.object_id = tbl.object_id
JOIN sys.allocation_units au ON au.container_id = p.hobt_id
JOIN sys.filegroups fg ON fg.data_space_id = au.data_space_id
WHERE (fg.name = @TableSpace OR @TableSpace IS NULL)

UPDATE msdb.dbo.SmartShrinkParams SET GetIndex = 1 WHERE spid = @spid;

INSERT INTO msdb.dbo.SmartShrinkLog( MsgText) VALUES('#SmartShrink.#GetData: index get finish.');
END
GO
IF OBJECT_ID ('tempdb..#CreateIndex','P') IS NOT NULL
	DROP PROCEDURE #CreateIndex;
GO
CREATE PROCEDURE #CreateIndex (@spid INT) 
AS 
BEGIN
DECLARE @ObjName NVARCHAR(513), @QueryExec NVARCHAR(MAX);
DECLARE curCreate CURSOR FOR SELECT ObjectName,QueryCrtIndex FROM msdb.dbo.SmartShrink WHERE spid = @spid AND EndCreate IS NULL;

BEGIN TRY 		
	OPEN curCreate;
	FETCH NEXT FROM curCreate INTO @ObjName,@QueryExec
	WHILE @@FETCH_STATUS = 0 BEGIN
	
		UPDATE msdb.dbo.SmartShrink
		SET StartCreate=GETDATE()
		WHERE ObjectName = @ObjName;

		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText, QueryText)
		VALUES('#SmartShrink.#CreateIndex: before operation.',@QueryExec);
		EXECUTE sp_executesql @QueryExec;
		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText, QueryText)
		VALUES('#SmartShrink.#CreateIndex: after operation.',@QueryExec);

		UPDATE msdb.dbo.SmartShrink
		SET EndCreate=GETDATE()
		WHERE ObjectName = @ObjName;

		FETCH NEXT FROM curCreate INTO @ObjName,@QueryExec	
	END
	CLOSE curCreate;
	DEALLOCATE curCreate;
END TRY
BEGIN CATCH
	CLOSE curCreate;
	DEALLOCATE curCreate;
	THROW;
END CATCH
UPDATE msdb.dbo.SmartShrinkParams SET CreateIndex = 1 WHERE spid = @spid;
END
GO
IF OBJECT_ID ('tempdb..#ShrinkFile','P') IS NOT NULL
	drop PROCEDURE #ShrinkFile;
GO
CREATE PROCEDURE #ShrinkFile(@spid INT,@TableSpace sysname = NULL,@ReserveFreeSpaceMB INT = 10)
AS 
BEGIN
DECLARE @QueryExec NVARCHAR(MAX);
DECLARE curShrink CURSOR FOR SELECT N'USE '+QUOTENAME(DB_NAME())+N';
'+N'DBCC SHRINKFILE ('+CAST(a.FILEID AS NVARCHAR)+N','+CONVERT(NVARCHAR,(convert(int,round(fileproperty(a.name,'SpaceUsed')/128.000,3))+@ReserveFreeSpaceMB))+N')' 
									FROM
									sys.sysfiles a
									INNER join sys.database_files df on df.file_id = a.fileid
									inner join sys.filegroups as fg on fg.data_space_id =  df.data_space_id
									WHERE fg.name=@TableSpace OR @TableSpace IS NULL;
BEGIN TRY 		
	OPEN curShrink;
	FETCH NEXT FROM curShrink INTO @QueryExec
	WHILE @@FETCH_STATUS = 0 BEGIN
	
		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText, QueryText)
		VALUES('#SmartShrink.#ShrinkFile: before operation.',@QueryExec);
		EXECUTE sp_executesql @QueryExec;
		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText, QueryText)
		VALUES('#SmartShrink.#ShrinkFile: after operation.',@QueryExec);

		FETCH NEXT FROM curShrink INTO @QueryExec	
	END
	CLOSE curShrink;
	DEALLOCATE curShrink;
END TRY
BEGIN CATCH
	CLOSE curShrink;
	DEALLOCATE curShrink;
	THROW;
END CATCH
UPDATE msdb.dbo.SmartShrinkParams SET ShrinkFile = 1 WHERE spid = @spid;
END 
GO
IF OBJECT_ID ('tempdb..#DropIndex','P') IS NOT NULL
	drop PROCEDURE #DropIndex;
GO
CREATE PROCEDURE #DropIndex (@spid INT) 
AS 
BEGIN
DECLARE @ObjName NVARCHAR(513), @QueryExec NVARCHAR(MAX);
DECLARE curDrop CURSOR FOR SELECT ObjectName,QueryDrpIndex FROM msdb.dbo.SmartShrink WHERE spid = @spid AND EndDrop IS NULL;

BEGIN TRY 		
	OPEN curDrop;
	FETCH NEXT FROM curDrop INTO @ObjName,@QueryExec
	WHILE @@FETCH_STATUS = 0 BEGIN
	
		UPDATE msdb.dbo.SmartShrink
		SET StartDrop=GETDATE()
		WHERE ObjectName = @ObjName;

		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText, QueryText)
		VALUES('#SmartShrink.#DropIndex before operation.',@QueryExec);
		EXECUTE sp_executesql @QueryExec;
		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText, QueryText)
		VALUES('#SmartShrink.#DropIndex after operation.',@QueryExec);

		UPDATE msdb.dbo.SmartShrink
		SET EndDrop=GETDATE()
		WHERE ObjectName = @ObjName;

		FETCH NEXT FROM curDrop INTO @ObjName,@QueryExec	
	END
	CLOSE curDrop;
	DEALLOCATE curDrop;
END TRY
BEGIN CATCH
	CLOSE curDrop;
	DEALLOCATE curDrop;
	THROW;
END catch
UPDATE msdb.dbo.SmartShrinkParams SET DropIndex = 1 WHERE spid = @spid;
END
GO
/*****************************************************************************************************************/
/* “”“ Ќј„јЋќ ¬’ќƒЌџ≈ ѕј–јћ≈“–џ */
DECLARE 	
	@ReserveFreeSpaceMB INT = 10,
	@TableSpace sysname = 'FG_2016';

/* —»—“≈ћЌџ≈ ѕј–јћ≈“–џ */
DECLARE 
	@spid INT = @@SPID,
	@GetIndex BIT = 0,
	@CreateIndex BIT = 0,
	@ShrinkFile BIT = 0,
	@DropIndex BIT = 0;

DECLARE @RunTable TABLE (spid INT,getIndex BIT,CreateIndex BIT,ShrinkFile BIT,DropIndex BIT);

INSERT INTO msdb.dbo.SmartShrinkLog( MsgText) VALUES('#SmartShrink. start.');

BEGIN TRY
	-- загружаем прерванные сессии или создаем новую.
	INSERT INTO @RunTable( spid ,getIndex ,CreateIndex ,ShrinkFile ,DropIndex)
	SELECT TOP 1 spid,GetIndex,CreateIndex,ShrinkFile,DropIndex 
	FROM msdb.dbo.SmartShrinkParams 
	
	IF EXISTS (SELECT 1 FROM @RunTable) BEGIN		
		SELECT 
			@spid = spid,
			@GetIndex = getIndex,
			@CreateIndex = CreateIndex,
			@ShrinkFile = ShrinkFile,
			@DropIndex = DropIndex
		FROM @RunTable;
		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText) VALUES('Find terminate session #'+CAST(@spid AS varchar));
	END ELSE BEGIN   
		INSERT INTO msdb.dbo.SmartShrinkParams( spid )VALUES(@spid);
		INSERT INTO msdb.dbo.SmartShrinkLog( MsgText) VALUES('Open new session #'+CAST(@spid AS varchar));
	END 

	-- получаем индексы
	IF @GetIndex = 0
		EXEC dbo.#GetIndex @spid = @spid, @TableSpace = @TableSpace

	-- построим индексы
--	IF @CreateIndex = 0
--		EXEC dbo.#CreateIndex @spid = @spid
		
	-- жмем файлы
--	IF @ShrinkFile = 0
--		EXEC dbo.#ShrinkFile @spid = @spid, @TableSpace = @TableSpace,@ReserveFreeSpaceMB = @ReserveFreeSpaceMB
		
	-- ”дал¤ем индексы
--	IF @DropIndex = 0 
--		EXEC dbo.#DropIndex @spid = @spid

	-- “ипо все хорошо
--	DELETE FROM msdb.dbo.SmartShrinkParams WHERE spid = @spid
		
END TRY
BEGIN CATCH
	DECLARE 
	@ErrorNumber INT = ERROR_NUMBER(),
	@ErrorSeverity INT = ERROR_SEVERITY(),
	@ErrorState INT = ERROR_STATE(),
	@ErrorLine INT = ERROR_LINE(),
	@ErrorMessage VARCHAR(4000) = ERROR_MESSAGE();

	IF XACT_STATE() = -1
			ROLLBACK TRAN
		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION

	insert into msdb.dbo.SmartShrinkLog( MsgText, QueryText, SPID )
	SELECT 'Error #'+CAST(@ErrorNumber AS VARCHAR)+' in line #'+CAST(@ErrorLine AS VARCHAR),@ErrorMessage,@spid;

	RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)  WITH LOG;
END CATCH;

INSERT INTO msdb.dbo.SmartShrinkLog( MsgText) VALUES('#SmartShrink. finish.');
GO
/*****************************************************************************************************************/