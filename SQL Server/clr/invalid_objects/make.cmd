set cc=%windir%\Microsoft.NET\Framework\v4.0.30319\csc.exe
set cc64=%windir%\Microsoft.NET\Framework64\v4.0.30319\csc.exe
%cc64% /out:out\InvalidObjects_x64.dll /target:library /platform:x64 InvalidObject.cs AssemblyInfo.cs
%cc%   /out:out\InvalidObjects_x86.dll /target:library /platform:x86 InvalidObject.cs AssemblyInfo.cs
