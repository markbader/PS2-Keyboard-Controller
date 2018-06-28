----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.06.2018 22:24:49
-- Design Name: 
-- Module Name: keyboard_controler - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keyboard_controler is
    Port ( t_data : in STD_LOGIC;
           t_clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           ledort : buffer STD_LOGIC_VECTOR (7 downto 0);
           segmentort : out STD_LOGIC_VECTOR (14 downto 0));
end keyboard_controler;

architecture Behavioral of keyboard_controler is
    signal e0, f0, ef, ce, ready : STD_LOGIC;
    signal scancode_reg, scancode, akt_scancode : STD_LOGIC_VECTOR(7 downto 0);
    signal seg_akt, seg_7, seg_6, seg_5, seg_4, seg_3, seg_2, seg_1, seg_0 : STD_LOGIC_VECTOR (6 downto 0);
    signal counter : STD_LOGIC_VECTOR(12 downto 0);
    signal scan_counter : STD_LOGIC_VECTOR(3 downto 0);
    type state is (s1, s2);
    signal s : state;
begin

    create_scancode : process (t_clock, t_data, scan_counter)
        begin
            if t_clock'event and t_clock = '0' then
                case scan_counter is
                    when "0001" =>  scancode_reg(0) <= t_data;
                    when "0010" =>  scancode_reg(1) <= t_data;
                    when "0011" =>  scancode_reg(2) <= t_data;
                    when "0100" =>  scancode_reg(3) <= t_data;
                    when "0101" =>  scancode_reg(4) <= t_data;
                    when "0110" =>  scancode_reg(5) <= t_data;
                    when "0111" =>  scancode_reg(6) <= t_data;
                    when "1000" =>  scancode_reg(7) <= t_data;
                    when "1001" =>  scancode <= scancode_reg;
                                    ready <= '1';
                    when "1010" =>  scan_counter <= "1111";
                    when others =>  scan_counter <= scan_counter;
                end case;
                scan_counter <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned( scan_counter )) +1, 4));
            end if;
        end process create_scancode;

    komp_e0 : process (scancode)
        begin
            if scancode = "11100000" then
                e0 <= '1';
            else
                e0 <= '0';
            end if;
        end process komp_e0;
        
    komp_f0 : process (scancode)
        begin
            if scancode = "11110000" then
                f0 <= '1';
            else
                f0 <= '0';
            end if;
        end process komp_f0;

    MUX_ledort : process (ready, ef, scancode, ledort)
        begin
            case STD_LOGIC_VECTOR'(ready, ef) is
                when "10" => akt_scancode <= scancode;
                when others => akt_scancode <= ledort;
            end case;
        end process MUX_ledort;
    
    OR_ef : process (e0, f0)
        begin
            ef <= e0 or f0;
        end process OR_ef;
        
    FF_ledort : process (clk, akt_scancode, reset)
        begin
            if reset = '1' then
                ledort <= "00000000";
            elsif clk'event and clk = '1' then
                ledort <= akt_scancode;
            end if;
        end process FF_ledort;
        
    hex2seven : process (akt_scancode)
        begin
            case akt_scancode is
                when "00011100" => seg_akt <= "0001000"; -- A
                when "00110010" => seg_akt <= "1100000"; -- B
                when "00100001" => seg_akt <= "0110001"; -- C
                when "00100011" => seg_akt <= "1000010"; -- D
                when "00100100" => seg_akt <= "0110000"; -- E
                when "00101011" => seg_akt <= "0111000"; -- F
                when "00110011" => seg_akt <= "1001000"; -- H
                when "01000011" => seg_akt <= "1111001"; -- I
                when "00111011" => seg_akt <= "1000111"; -- J
                when "01001011" => seg_akt <= "1110001"; -- L
                when "01001101" => seg_akt <= "0011000"; -- P
                when "01000101" => seg_akt <= "0000001"; -- 0
                when "00010110" => seg_akt <= "1001111"; -- 1
                when "00011110" => seg_akt <= "0010010"; -- 2
                when "00100110" => seg_akt <= "0000110"; -- 3
                when "00100101" => seg_akt <= "1001100"; -- 4
                when "00101110" => seg_akt <= "0100100"; -- 5
                when "00110110" => seg_akt <= "0100000"; -- 6
                when "00111101" => seg_akt <= "0001111"; -- 7
                when "00111110" => seg_akt <= "0000000"; -- 8
                when "01000110" => seg_akt <= "0000100"; -- 9
                when others => seg_akt <= "1000001";     -- Undefined
            end case;
        end process hex2seven;
        
    FF_seg_7 : process (seg_akt, reset, ce, clk)
        begin
            if reset = '1' then
                seg_7 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_7 <= seg_akt;
            end if;
        end process FF_seg_7;
    
    FF_seg_6 : process (seg_7, reset, ce, clk)
        begin
            if reset = '1' then
                seg_6 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_6 <= seg_7;
            end if;
        end process FF_seg_6;
    
    FF_seg_5 : process (seg_6, reset, ce, clk)
        begin
            if reset = '1' then
                seg_5 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_5 <= seg_6;
            end if;
        end process FF_seg_5;
    
    FF_seg_4 : process (seg_5, reset, ce, clk)
        begin
            if reset = '1' then
                seg_4 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_4 <= seg_5;
            end if;
        end process FF_seg_4;
    
    FF_seg_3 : process (seg_4, reset, ce, clk)
        begin
            if reset = '1' then
                seg_3 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_3 <= seg_4;
            end if;
        end process FF_seg_3;

    FF_seg_2 : process (seg_3, reset, ce, clk)
        begin
            if reset = '1' then
                seg_2 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_2 <= seg_3;
            end if;
        end process FF_seg_2;

    FF_seg_1 : process (seg_2, reset, ce, clk)
        begin
            if reset = '1' then
                seg_1 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_1 <= seg_2;
            end if;
        end process FF_seg_1;

    FF_seg_0 : process (seg_1, reset, ce, clk)
        begin
            if reset = '1' then
                seg_0 <= "1111111";
            elsif clk'event and clk = '1' and ce = '1' then
                seg_0 <= seg_1;
            end if;
        end process FF_seg_0;
    
    MUX_segmentort : process (seg_3, seg_2, seg_1, seg_0, counter(11), counter(12))
        begin
            case STD_LOGIC_VECTOR'(counter(12), counter(11), counter(10)) is
                when "000" => segmentort <= "01111111"&seg_7;
                when "001" => segmentort <= "10111111"&seg_6;
                when "010" => segmentort <= "11011111"&seg_5;
                when "011" => segmentort <= "11101111"&seg_4;
                when "100" => segmentort <= "11110111"&seg_3;
                when "101" => segmentort <= "11111011"&seg_2;
                when "110" => segmentort <= "11111101"&seg_1;
                when "111" => segmentort <= "11111110"&seg_0;
                when others => segmentort <= "11111111"&seg_3;
            end case;
        end process MUX_segmentort;

    takt_teiler : process (clk)
        begin
            if clk'event and clk = '1' then
                 counter <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned( counter )) +1, 13));
            end if;
        end process takt_teiler;
        
    stw : process (reset, ready, e0, f0, s, clk)
        begin
            if clk'event and clk = '1' then
                case s is
                    when s1 => case ready is
                                    when '1' => case STD_LOGIC_VECTOR'(e0, f0) is
                                                    when "00" => ce <= '1';
                                                    when "10" => ce <= '0';
                                                    when others => ce <= '0';
                                                                    s <= s2;
                                                end case;
                                    when '0' => ce <= '0';
                                end case;
                    when s2 =>  case ready is
                                    when '1' => ce <= '0';
                                                s <= s1;
                                    when '0' => ce <= '0';
                                                s <= s2;
                                end case;
                end case;
            end if;
        end process stw;
    
end Behavioral;
