LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

type niz is array(0 to 1505) of STD_LOGIC_VECTOR(7 downto 0);
type nizOut is array(0 to 499) of STD_LOGIC_VECTOR(7 downto 0);
type kernel is array(0 to 2) of SIGNED(7 downto 0);


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
        out_buff_size : OUT INTEGER := 1;
        nizIN : in niz;
        nizOUT : OUT nizOut

    );
END ENTITY edgeDetection;

ARCHITECTURE behavioural OF project_io IS
    SIGNAL temp_data : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL done_s : STD_LOGIC := '0';
    
    constant row1 : kernel := (to_signed(0, 8), to_signed(-1, 8), to_signed(0, 8));
    constant row2 : kernel := (to_signed(-1, 8), to_signed(4, 8), to_signed(-1, 8));
    constant row3 : kernel := (to_signed(0, 8), to_signed(-1, 8), to_signed(0, 8));

    
    

BEGIN
    PROCESS (clk, rst)
        variable nb1, nb2, nb3 : INTEGER;
        variable sum : signed(15 downto 0); 
        
    BEGIN
        

        IF rst = '1' THEN
            done <= '0';
            in_read_enable <= '0';
            out_write_enable <= '0';
        ELSIF rising_edge(clk) THEN
            IF enable = '1' AND done = '0' THEN
                in_read_enable <= '0';
                out_write_enable <= '0';

                nb1 := 0;
                nb2 := 502;
                nb3 := 1004;

                for y in 0 to 499 loop
                    sum := (others => '0');

                    for i in 0 to 2 loop
                        sum := sum +
                            signed(nizIN(nb1)) * signed(row1(i)) +
                            signed(nizIN(nb2)) * signed(row2(i)) +
                            signed(nizIN(nb3)) * signed(row3(i));

                        nb1 := nb1 + 1;
                        nb2 := nb2 + 1;
                        nb3 := nb3 + 1;
                    end loop;
                    nb1 := nb1 - 2;
                    nb2 := nb2 - 2;
                    nb3 := nb3 - 2;

                    if sum < 0 then
                        nizOUT(y) <= std_logic_vector(to_unsigned(0, 8));
                    elsif sum > 255 then
                        nizOUT(y) <= std_logic_vector(to_unsigned(255, 8));
                    else
                        nizOUT(y) <= std_logic_vector(resize(unsigned(sum), 8));
                    end if;

                    
                end loop;

        
                done <= '1';
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE behavioural;