

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

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
        in_buff_size : OUT INTEGER;
        out_buff_size : OUT INTEGER
    );
END ENTITY edgeDetection;

ARCHITECTURE behavioural OF edgeDetection IS

    TYPE kernel IS ARRAY(0 TO 2) OF SIGNED(7 DOWNTO 0);

    CONSTANT row1 : kernel := (to_signed(0, 8),  to_signed(-1, 8), to_signed(0, 8));
    CONSTANT row2 : kernel := (to_signed(-1, 8), to_signed(4, 8),  to_signed(-1, 8));
    CONSTANT row3 : kernel := (to_signed(0, 8),  to_signed(-1, 8), to_signed(0, 8));

    SIGNAL state : INTEGER := 0;
    SIGNAL sum : SIGNED(15 DOWNTO 0) := (others => '0');

    SIGNAL y : INTEGER := 0;  -- output pixel index (0 to 499)
    SIGNAL pixel_index : INTEGER := 0; -- index za čitanje
    SIGNAL read_counter : INTEGER := 0;

    TYPE pixel_array IS ARRAY(0 TO 1505) OF SIGNED(7 DOWNTO 0); --///////
    SIGNAL window : pixel_array := (OTHERS => (OTHERS => '0'));

BEGIN

    in_buff_size <= 1506;
    out_buff_size <= 500;

    PROCESS(clk, rst)
    variable nb1, nb2, nb3 : INTEGER;
    BEGIN
        IF rst = '1' THEN
            state <= 0;
            done <= '0';
            in_read_enable <= '0';
            out_write_enable <= '0';
            in_index <= 0;
            out_index <= 0;
            sum <= (others => '0');
            y <= 0;
            read_counter <= 0;

        ELSIF rising_edge(clk) THEN
            CASE state IS

                WHEN 0 =>
                    IF enable = '1' THEN
                        pixel_index <= 0;
                        read_counter <= 0;
                        in_index <= 0;
                        in_read_enable <= '1';
                        nb1 := 0;
                        nb2 := 502;
                        nb3 := 1004;
                        state <= 1;
                    END IF;

                WHEN 1 => 
                    in_read_enable <= '0';
                    state <= 2;

                WHEN 2 => -
                    window(read_counter) <= signed(in_data);
                    read_counter <= read_counter + 1;
                    pixel_index <= pixel_index + 1;

                    IF read_counter < 502 THEN
                        in_index <= pixel_index + 1;
                        in_read_enable <= '1';
                        state <= 1;
                    ELSE
                        state <= 3;
                    END IF;

                WHEN 3 =
                    
                    

                    FOR i IN 0 TO 2 LOOP
                        sum := sum +
                            signed(window(nb1)) * to_signed(row1(i)) + --//////
                            signed(window(nb2)) * to_signed(row2(i)) + --//////
                            signed(window(nb3)) * to_signed(row3(i)); 

                        nb1 := nb1 + 1;
                        nb2 := nb2 + 1;
                        nb3 := nb3 + 1;
                    END LOOP;
                    nb1 := nb1 - 2;
                    nb2 := nb2 - 2;
                    nb3 := nb3 - 2;

                    

                    out_index <= y;
                    state <= 4
                END LOOP;

                WHEN 4 => -- Priprema za izlaz
                    IF sum < 0 THEN
                        out_data <= std_logic_vector(to_unsigned(0, 8));
                    ELSIF sum > 255 THEN
                        out_data <= std_logic_vector(to_unsigned(255, 8));
                    ELSE
                        out_data <= std_logic_vector(resize(unsigned(sum), 8));
                    END IF;

                    
                    out_write_enable <= '1';
                    state <= 5;

                WHEN 5 => 
                    out_write_enable <= '0';
                    

                    IF y = 499 THEN
                        done <= '1';
                        state <= 6;
                    ELSE
                        y <= y + 1
                        pixel_index <= y + 1;
                        read_counter <= 0;
                        in_index <= y + 1;
                        in_read_enable <= '1';
                        state <= 1;
                    END IF;

                WHEN 6 =>
                   
                    done <= '1';

                WHEN OTHERS =>
                    state <= 0;

            END CASE;
        END IF;
    END PROCESS;

END ARCHITECTURE behavioural;