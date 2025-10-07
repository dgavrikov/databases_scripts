# Инструкция по использованию класса AccountChecksum

## Введение
Класс `AccountChecksum` — это статический класс на C#, предназначенный для расчета и проверки контрольных сумм банковских номеров лицевых счетов в России согласно стандарту Центрального Банка РФ (ПОРЯДОК РАСЧЕТА КОНТРОЛЬНОГО КЛЮЧА В НОМЕРЕ ЛИЦЕВОГО СЧЕТА от 8 сентября 1997 г. № 515). Он включает методы для валидации BIC, преобразования масок, расчета checksum и проверки номеров счетов. Класс предназначен для использования в SQL Server как пользовательские функции (атрибуты `[Microsoft.SqlServer.Server.SqlFunction]`).

**Предварительные требования:**
- .NET Framework или .NET Core с поддержкой SQL Server CLR.
- Знание BIC (9-значный код банка) и номеров лицевых счетов (20 символов, включая контрольную сумму).

## Шаг 1: Проверка BIC
Используйте приватный метод `IsBic(string bic)` для валидации BIC:
- BIC не должен быть пустым или состоять из пробелов.
- Должен содержать только цифры.
- Длина ровно 9 символов.

Пример:
```csharp
bool isValidBic = IsBic("044525225"); // true, если BIC валиден
```

## Шаг 2: Преобразование маскированного номера счета
Используйте приватный метод `Unmask(string mask, int num)` для замены плейсхолдеров 'x' в маске на цифры из числа `num`:
- Маска — строка с 'x' (например, "12345x78901234567890").
- `num` форматируется до 20 цифр и заменяет 'x' с конца.
- Возвращает строку или null, если маска пустая.

Пример:
```csharp
string unmasked = Unmask("12345x78901234567890", 123456789); // Результат: "12345678901234567890"
```

## Шаг 3: Цифровизация номера счета
Используйте приватный метод `digitizeAccountNumber(string accountNumber)` для замены 6-го символа, если он буква:
- Допустимые буквы: A, B, C, E, H, K, M, P, T, X (заменяются на индекс 0-9).
- Возвращает строку с цифрами.

Пример:
```csharp
string digitized = digitizeAccountNumber("12345A78901234567890"); // Результат: "12345078901234567890"
```

## Шаг 4: Расчет взвешенных произведений
Используйте приватный метод `calculateWeightedProducts(string accountNumber, string bic, bool bicIsRkc)`:
- Вычисляет массив из 23 элементов на основе весов (`m_WeightsForAccountNumber`).
- Для обычных BIC использует последние 3 цифры; для РКЦ (bicIsRkc=true) — 5-ю и 6-ю.
- Номер счета должен быть 20 цифр.

Пример:
```csharp
int[] products = calculateWeightedProducts("12345678901234567890", "044525225", false);
```

## Шаг 5: Расчет контрольной суммы
Используйте публичный метод `CalculateAccountChecksum(string accountNumber, string bic, bool bicIsRkc = false)`:
- Введите номер счета (20 символов) и BIC.
- Метод проверит валидность, преобразует счет и рассчитает checksum: `((sum % 10) * 3) % 10`.
- Бросает исключение при ошибках.

Пример:
```csharp
int checksum = CalculateAccountChecksum("12345678901234567890", "044525225"); // Возвращает int (0-9)
```

## Шаг 6: Раскрытие маски с контрольной суммой
Используйте публичный метод `UnmaskBankAccount(string mask, string bic, int num)`:
- Раскрывает маску, рассчитывает checksum и вставляет его в 9-ю позицию (заменяя 8-й символ).
- Возвращает полный 20-значный номер счета.

Пример:
```csharp
string fullAccount = UnmaskBankAccount("12345x78x01234567890", "044525225", 123456789); // Вставляет checksum
```

## Шаг 7: Проверка валидности номера счета
Используйте публичный метод `IsValidAccountNumber(string accountNumber, string bic, bool bicIsRkc = false)`:
- Введите номер счета (20 символов) и BIC.
- Возвращает true, если сумма взвешенных произведений % 10 == 0.

Пример:
```csharp
bool isValid = IsValidAccountNumber("12345678901234567890", "044525225"); // true или false
```

## Примечания и советы
- Все публичные методы бросают `ArgumentOutOfRangeException` при неверных входных данных (пустые строки, неправильная длина, нецифры).
- Параметр `bicIsRkc` установите в true, если BIC принадлежит Расчетно-Кассовому Центру.
- Для интеграции в SQL Server скомпилируйте класс в сборку и зарегистрируйте функции.
- Тестируйте на реальных данных; код не обрабатывает все edge-cases (например, неиспользуемые поля как `m_WeightsForInn`).

## Установка в SQL Server
Для использования класса в SQL Server выполните следующие шаги (предполагается, что DLL находится по пути `c:\clr\AccountChecksum_x64.dll` и сборка называется `AccountChecksum`):

```sql
sp_configure 'advanced options',1;
GO
reconfigure with override;
GO
sp_configure 'clr enabled',1
GO
reconfigure with override;
GO

create assembly [AccountChecksum]
from 'c:\clr\AccountChecksum_x64.dll'
with permission_set = safe;
GO

create function dbo.UnmaskBankAccount(@mask nvarchar(20),@bic nvarchar(9),@num int) returns nvarchar(50)
as external name [AccountChecksum].[AccountChecksum].UnmaskBankAccount
GO

create function dbo.CalculateAccountChecksum(@accountNumber nvarchar(20),@bic nvarchar(9),@bicIsRkc bit=false) returns int
as external name [AccountChecksum].[AccountChecksum].CalculateAccountChecksum
GO

create function dbo.IsValidAccountNumber(@accountNumber nvarchar(20),@bic nvarchar(9),@bicIsRkc bit=false) returns bit
as external name [AccountChecksum].[AccountChecksum].IsValidAccountNumber
GO
```

Если нужны примеры кода или дополнительные детали, уточните.