-- Autor reseni: Ondrej Dohnal xdohna45
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY ledc8x8 IS
    PORT (-- Sem doplnte popis rozhrani obvodu.
        SMCLK : IN std_logic; -- hlavní hodinový signál
        RESET : IN std_logic; -- signál pro asynchonní inicializaci hodnot
        ROW : OUT std_logic_vector(0 TO 7); -- signály pro výběr řádku matice
        LED : OUT std_logic_vector(0 TO 7) -- signály pro výběr sloupce matice
    );
END ledc8x8;

ARCHITECTURE main OF ledc8x8 IS
    -- povolovací signál
    SIGNAL ce : std_logic := '0';
    -- signál pro čítač generující ce
    SIGNAL ce_cnt : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    -- signal pro citac na bliknuti
    SIGNAL blik_clk : std_logic_vector(21 DOWNTO 0) := (OTHERS => '0');
    -- signály posílané do ROW (10000000 = 1. řádek)
    SIGNAL rows_active : std_logic_vector(0 TO 7) := (OTHERS => '0');
    -- singály posílané do LED (11111111 = všechny LED jsou neaktivní)
    SIGNAL cols_active : std_logic_vector(0 TO 7) := (OTHERS => '1');
    -- signal na blinuti
    SIGNAL blink : std_logic := '0';
    -- signal na povoleni displeje
    SIGNAL enable : std_logic := '1';
    -- signal aby se to neopakovalo
    SIGNAL once : std_logic_vector(0 TO 1) := "00";
BEGIN

    ce_gen : PROCESS (SMCLK, RESET)
    BEGIN
        IF RESET = '1' THEN
            ce_cnt <= (OTHERS => '0');
        ELSIF SMCLK'event AND SMCLK = '1' THEN
            ce_cnt <= ce_cnt + 1;
        END IF;
    END PROCESS ce_gen;
    ce <= '1' WHEN ce_cnt = X"FF" ELSE
        '0';

    blik_gen : PROCESS (SMCLK, RESET)
    BEGIN
        IF RESET = '1' THEN
            blik_clk <= (OTHERS => '0');
        ELSIF SMCLK'event AND SMCLK = '1' THEN
            blik_clk <= blik_clk + '1';
        END IF;
        IF blik_clk = X"384001" THEN
            blik_clk <= (OTHERS => '0');
        END IF;
    END PROCESS blik_gen;
    blink <= '1' WHEN blik_clk = X"384000" ELSE
        '0';

    blikac : PROCESS (blink, once)
    BEGIN
        IF once = "00" OR once = "01" OR once = "10" THEN
            IF blink'event AND blink = '1' THEN
                IF once = "00" THEN
                    enable <= '0';
                    once <= "01";
                ELSIF once = "01" THEN
                    enable <= '1';
                    once <= "10";
                ELSIF once = "10" THEN
                    enable <= '1';
                    once <= "11";
                END IF;
            END IF;
        END IF;
    END PROCESS blikac;

    led_set : PROCESS (rows_active, enable)
    BEGIN
        IF enable = '1' THEN
            CASE rows_active IS
                WHEN "10000000" => cols_active <= "10011111";
                WHEN "01000000" => cols_active <= "01101111";
                WHEN "00100000" => cols_active <= "01101111";
                WHEN "00010000" => cols_active <= "01101001";
                WHEN "00001000" => cols_active <= "01101010";
                WHEN "00000100" => cols_active <= "10011010";
                WHEN "00000010" => cols_active <= "11111010";
                WHEN "00000001" => cols_active <= "11111001";
                WHEN OTHERS => cols_active <= "11111111";
            END CASE;
        ELSE
            cols_active <= "11111111";
        END IF;
    END PROCESS led_set;
    LED <= cols_active;

    row_set : PROCESS (SMCLK, RESET, ce)
    BEGIN
        IF RESET = '1' THEN
            rows_active <= "10000000";
        ELSIF ce'event AND ce = '1' THEN
            rows_active <= rows_active(7) & rows_active(0 TO 6);
        END IF;

    END PROCESS row_set;
    ROW <= rows_active;
END main;
-- ISID: 75579