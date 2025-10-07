-- Функция для проверки BIC (аналог IsBic)
CREATE OR REPLACE FUNCTION is_bic_valid(bic TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    IF bic IS NULL OR LENGTH(TRIM(bic)) <> 9 OR bic !~ '^[0-9]+$' THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Функция для цифровизации номера счета (аналог digitizeAccountNumber)
CREATE OR REPLACE FUNCTION digitize_account_number(account_number TEXT)
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
    char_val TEXT;
    digit_map CONSTANT TEXT[] := ARRAY['0','1','2','3','4','5','6','7','8','9']; -- A=0, B=1, ..., X=9
    idx INT;
BEGIN
    IF LENGTH(account_number) <> 20 THEN
        RAISE EXCEPTION 'Account number must be 20 characters';
    END IF;
    FOR i IN 1..20 LOOP
        char_val := SUBSTRING(account_number, i, 1);
        IF i = 6 THEN
            -- Замена буквы на цифру
            idx := POSITION(UPPER(char_val) IN 'ABCEHKMPTX');
            IF idx > 0 THEN
                result := result || digit_map[idx];
            ELSIF char_val ~ '^[0-9]$' THEN
                result := result || char_val;
            ELSE
                RAISE EXCEPTION 'Invalid character at position 6';
            END IF;
        ELSE
            IF char_val ~ '^[0-9]$' THEN
                result := result || char_val;
            ELSE
                RAISE EXCEPTION 'Account number must contain only digits except position 6';
            END IF;
        END IF;
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Функция для расчета контрольной суммы (аналог CalculateAccountChecksum)
CREATE OR REPLACE FUNCTION calculate_account_checksum(account_number TEXT, bic TEXT, bic_is_rkc BOOLEAN DEFAULT FALSE)
RETURNS INTEGER AS $$
DECLARE
    digitized TEXT;
    weights CONSTANT INTEGER[] := ARRAY[
        7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1
    ]; -- 23 веса
    products INTEGER[] := ARRAY[]::INTEGER[];
    sum_val INTEGER := 0;
    bic_part TEXT;
    i INT;
BEGIN
    IF NOT is_bic_valid(bic) THEN
        RAISE EXCEPTION 'Invalid BIC';
    END IF;
    digitized := digitize_account_number(account_number);
    IF bic_is_rkc THEN
        bic_part := SUBSTRING(bic, 5, 2);
    ELSE
        bic_part := SUBSTRING(bic, 7, 3);
    END IF;
    -- Строим массив для расчета
    FOR i IN 1..23 LOOP
        IF i <= 3 THEN
            products[i] := (SUBSTRING(bic_part, i, 1)::INTEGER) * weights[i];
        ELSIF i >= 4 AND i <= 23 THEN
            products[i] := (SUBSTRING(digitized, i-3, 1)::INTEGER) * weights[i];
        END IF;
        sum_val := sum_val + products[i];
    END LOOP;
    RETURN ((sum_val % 10) * 3) % 10;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Функция для раскрытия маски с вставкой checksum (аналог UnmaskBankAccount)
CREATE OR REPLACE FUNCTION unmask_bank_account(mask TEXT, bic TEXT, num INTEGER)
RETURNS TEXT AS $$
DECLARE
    unmasked TEXT := '';
    num_str TEXT := LPAD(num::TEXT, 20, '0'); -- Форматируем num до 20 цифр
    checksum INTEGER;
    temp_account TEXT;
    i INT;
    x_count INT := 0;
BEGIN
    IF mask IS NULL OR LENGTH(mask) <> 20 THEN
        RAISE EXCEPTION 'Mask must be 20 characters';
    END IF;
    -- Считаем 'x' и заменяем с конца
    FOR i IN REVERSE 1..20 LOOP
        IF SUBSTRING(mask, i, 1) = 'x' THEN
            x_count := x_count + 1;
            unmasked := SUBSTRING(num_str, 21 - x_count, 1) || unmasked;
        ELSE
            unmasked := SUBSTRING(mask, i, 1) || unmasked;
        END IF;
    END LOOP;
    -- Рассчитываем checksum и вставляем в 9-ю позицию (заменяя 8-й символ, как в оригинале)
    checksum := calculate_account_checksum(unmasked, bic);
    temp_account := SUBSTRING(unmasked, 1, 7) || checksum::TEXT || SUBSTRING(unmasked, 9);
    RETURN temp_account;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Функция для проверки валидности (аналог IsValidAccountNumber)
CREATE OR REPLACE FUNCTION is_valid_account_number(account_number TEXT, bic TEXT, bic_is_rkc BOOLEAN DEFAULT FALSE)
RETURNS BOOLEAN AS $$
DECLARE
    digitized TEXT;
    weights CONSTANT INTEGER[] := ARRAY[
        7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1
    ];
    products INTEGER[] := ARRAY[]::INTEGER[];
    sum_val INTEGER := 0;
    bic_part TEXT;
    i INT;
BEGIN
    IF NOT is_bic_valid(bic) THEN
        RETURN FALSE;
    END IF;
    digitized := digitize_account_number(account_number);
    IF bic_is_rkc THEN
        bic_part := SUBSTRING(bic, 5, 2);
    ELSE
        bic_part := SUBSTRING(bic, 7, 3);
    END IF;
    FOR i IN 1..23 LOOP
        IF i <= 3 THEN
            products[i] := (SUBSTRING(bic_part, i, 1)::INTEGER) * weights[i];
        ELSIF i >= 4 AND i <= 23 THEN
            products[i] := (SUBSTRING(digitized, i-3, 1)::INTEGER) * weights[i];
        END IF;
        sum_val := sum_val + products[i];
    END LOOP;
    RETURN (sum_val % 10) = 0;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
