using System;
using System.Linq;
using System.Text.RegularExpressions;

public static class AccountChecksum
{
    #region privates
    private static bool IsBic(string bic)
    {
        // simply check if it's not empty
        if (String.IsNullOrWhiteSpace(bic)) return false;

        // all symbols are digits
        if (!m_AllDigits.IsMatch(bic)) return false;

        // must be 9 symbols long
        if (bic.Length != 9) return false;

        return true;
    }
    private static string Unmask(string mask, int num)
    {
        if (string.IsNullOrWhiteSpace(mask)) return null;
        mask = mask.ToLower();
        if (!mask.Contains("x")) return mask;

        var masked = string.Format("{0:00000000000000000000}", num);

        var j = masked.Length - 1;
        var sb = mask.ToCharArray();
        for (var i = sb.Length - 1; i >= 0; i--)
        {
            if (j > 0 && mask[i] == 'x')
            {
                sb[i] = masked[j];
                j--;
            }
        }
        return string.Join("", sb);
    }
    private static readonly Regex m_AllDigits = new Regex(@"^\d+$", RegexOptions.Compiled);
    private static readonly int[] m_WeightsForAccountNumber = new int[23] { 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1 };
    private static readonly int[] m_WeightsForInn = new int[12] { 3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8, 0 };
    private static readonly char[] m_AllowedCodesForDigit6 = new char[10] { 'A', 'B', 'C', 'E', 'H', 'K', 'M', 'P', 'T', 'X' };
    private static readonly int[] m_Deltas = new[] { 0, 1, 2, 3, 4, -4, -3, -2, -1, 0 };
    private static string digitizeAccountNumber(string accountNumber)
    {
        // substitute allowed alphabet symbols
        char possibleSymbol = accountNumber[5];
        int index = Array.IndexOf(m_AllowedCodesForDigit6, possibleSymbol);
        if (index != -1)
        {
            accountNumber = accountNumber.Substring(0, 5) + Convert.ToString(index) + accountNumber.Substring(6, 14);
        }
        return accountNumber;
    }
    private static int[] calculateWeightedProducts(string accountNumber, string bic, bool bicIsRkc)
    {
        var result = new int[23];
        if (!bicIsRkc)
        {
            for (int i = 0; i < 3; i++)
            {
                result[i] = ((bic[i + 6] - 48) * m_WeightsForAccountNumber[i]) % 10;
            }
        }
        else
        {
            result[0] = 0;
            result[1] = ((bic[4] - 48) * m_WeightsForAccountNumber[1]) % 10;
            result[2] = ((bic[5] - 48) * m_WeightsForAccountNumber[2]) % 10;
        }

        for (int i = 0; i < 20; i++)
        {
            result[i + 3] = ((accountNumber[i] - 48) * m_WeightsForAccountNumber[i]) % 10;
        }
        return result;
    }
    #endregion
	
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string UnmaskBankAccount(string mask, string bic, int num)
    {
        if (string.IsNullOrWhiteSpace(mask)) return "";
        if (string.IsNullOrWhiteSpace(bic)) return "";

        var accountNumber = Unmask(mask, num);
        if (!IsBic(bic)) throw new ArgumentOutOfRangeException("bic", "Please provide valid BIC");
        var checksum = CalculateAccountChecksum(accountNumber, bic);
        return accountNumber.Remove(8, 1).Insert(8, string.Format("{0:0}", checksum));
    }
    /// <summary>
    /// Calculate account checksum for provided account number and bic
    /// ПОРЯДОК РАСЧЕТА КОНТРОЛЬНОГО КЛЮЧА В НОМЕРЕ ЛИЦЕВОГО СЧЕТА (ЦЕНТРАЛЬНЫЙ БАНК РОССИИ, 8 сентября 1997 г. N 515)
    /// </summary>
    /// <param name="accountNumber">Номер лицевого счета</param>
    /// <param name="bic">БИК - Банковский Идентификационный Код</param>
    /// <param name="bicIsRkc">true, если БИК принадлежит РКЦ (Расчетно-Кассовому Центру), иначе false. По умолчанию false</param>
    /// <returns><c>true</c> if valid, <c>false</c> otherwise</returns>
    [Microsoft.SqlServer.Server.SqlFunction]
    public static int CalculateAccountChecksum(string accountNumber, string bic, bool bicIsRkc = false)
    {
        // simply check if it's not empty
        if (String.IsNullOrWhiteSpace(accountNumber)) throw new ArgumentOutOfRangeException("accountNumber", "Account number can not be empty");
        // must be 20 symbols long
        if (accountNumber.Length != 20) throw new ArgumentOutOfRangeException("accountNumber", "Account number must be of length 20"); ;
        // validate bic
        if (!IsBic(bic)) throw new ArgumentOutOfRangeException("bic", "Please provide valid BIC");
        accountNumber = digitizeAccountNumber(accountNumber);
        // all symbols are digits now
        if (!m_AllDigits.IsMatch(accountNumber)) throw new ArgumentOutOfRangeException("accountNumber", "Account number must be valid account number");

        var p = calculateWeightedProducts(accountNumber, bic, bicIsRkc);
        p[11] = 0;
        return ((p.Sum() % 10) * 3) % 10;
    }
    /// <summary>
    /// Check is the string is a valid account number according to
    /// ПОРЯДОК РАСЧЕТА КОНТРОЛЬНОГО КЛЮЧА В НОМЕРЕ ЛИЦЕВОГО СЧЕТА (ЦЕНТРАЛЬНЫЙ БАНК РОССИИ, 8 сентября 1997 г. N 515)
    /// </summary>
    /// <param name="accountNumber">Номер лицевого счета</param>
    /// <param name="bic">БИК - Банковский Идентификационный Код</param>
    /// <param name="bicIsRkc">true, если БИК принадлежит РКЦ (Расчетно-Кассовому Центру), иначе false. По умолчанию false</param>
    /// <returns><c>true</c> if valid, <c>false</c> otherwise</returns>
    [Microsoft.SqlServer.Server.SqlFunction]
    public static bool IsValidAccountNumber(string accountNumber, string bic, bool bicIsRkc = false)
    {
        // simply check if it's not empty
        if (String.IsNullOrWhiteSpace(accountNumber)) return false;
        // validate bic
        if (!IsBic(bic)) return false;
        // must be 20 symbols long
        if (accountNumber.Length != 20) return false;

        accountNumber = digitizeAccountNumber(accountNumber);
        // all symbols are digits now
        if (!m_AllDigits.IsMatch(accountNumber)) return false;

        // calculate weighted products
        var p = calculateWeightedProducts(accountNumber, bic, bicIsRkc);

        // calculate checksum
        // p[11] = 0;
        // var checksum = ((p.Sum() %10)*3) %10;

        // verify checksum
        // p[11] = (checksum * m_Weights[11]) %10;

        int verify = p.Sum() % 10;
        return (verify == 0);
    }
}

