LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

type niz is array(0 to 1505) of STD_LOGIC_VECTOR(7 downto 0);
type nizOut is array(0 to 499) of STD_LOGIC_VECTOR(7 downto 0);
type kernel is array(0 to 2) of STD_LOGIC_VECTOR(7 downto 0)

ENTITY edgeDetection IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        done : OUT STD_LOGIC;
        in_read_enable : OUT STD_LOGIC;
        in_index : OUT INTEGER;
        in_data : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        out_write_enable : OUT STD_LOGIC;
        out_index : OUT INTEGER;
        out_data : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        in_buff_size : OUT INTEGER := 1;
        out_buff_size : OUT INTEGER := 1
        nizIN : in niz;
        nizOUT : OUT nizOut

    );
END ENTITY edgeDetection;

ARCHITECTURE behavioural OF project_io IS
    SIGNAL temp_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL done_s : STD_LOGIC := '0';
    SIGNAL row1 : kernel := ("00000000" , "11111111", "00000000");
    SIGNAL row2 : kernel := ("11111111" , "00000100", "11111111");
    SIGNAL row3 : kernel := ("00000000" , "11111111", "00000000");
    SIGNAL fk1 : kernel;
    SIGNAL fk2 : kernel;
    SIGNAL fk3 : kernel;
    SIGNAL data : nizOut;
    SIGNAL nb1 : INTEGER := 0;
    SIGNAL nb2 : INTEGER := 502;
    SIGNAL nb3 : INTEGER := 1004
    --TODO JEDAN BROJAC

BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            in_read_enable <= '0';
            out_write_enable <= '0';
            done <= '0';
        ELSIF rising_edge(clk) THEN
            IF enable = '1' AND done_s = '0' THEN
                in_read_enable <= '1';
                out_write_enable <= '1';
                in_index <= 0;
                out_index <= 0;
                temp_data <= in_data;
                out_data <= temp_data;
                done_s <= '1';
                done <= '0';

                for y in 0 to 499 loop
                    --prvi
                    for i in 0 to 2 loop
                        fk1(i) <= nizIN(nb1) * row1(i);
                        nb1 <= nb1 + 1;
                    end loop;
                    nb <= nb1 - 2;
                    --drugi
                    for i in 0 to 2 loop
                        fk2(i) <= nizIN(nb2) * row2(i);
                        nb2 <= nb2 + 1;
                    end loop;       
                    nb2 <= nb2 - 2;
                    --treci
                    for i in 0 to 2 loop
                        fk3(i) <= nizIN(nb3) * row3(i);
                        nb3 <= nb3 + 1;
                    end loop;       
                    nb3 <= nb3 - 2;
                    

                    for i in 0 to 2 loop
                        data(nb1) <= data(nb1) + fk1(i) + fk2(i) + fk3(i);
                    end loop;
                end loop;

                


            ELSIF done_s = '1' THEN
                done_s <= '0';
                done <= '1';
            ELSE
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE behavioural;