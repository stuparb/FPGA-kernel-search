LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

-- WHEN RUNNING THE TESTBENCH IT WILL END WITH THE MESSAGE END
-- AFTER THAT MESSAGE IT WILL SAY 'REPORT FAILED' AND 'SIMULATION FAILED' BUT PAY NO MIND TO THAT

-- EVERY TIME THE OUT_WRITE_ENABLE SIGNAL IS SET THE TESTBENCH WILL PRINT THE OUTPUT
-- TO THE CONSOLE INSTEAD OF WRITING IT INTO THE MEMORY

-- IT _MAY_ HAVE BUGS :)


ENTITY project_io_tb IS
GENERIC (
    IN_RAM_SIZE : NATURAL := 2;
    OUT_RAM_SIZE : NATURAL := 2;
    BUFFER_NUM : NATURAL := 6
);
END ENTITY project_io_tb;

ARCHITECTURE behavioural OF project_io_tb IS
    COMPONENT project_io IS
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
            out_buff_size : OUT INTEGER;

        );
    END COMPONENT;
    
    TYPE memory_array IS ARRAY(natural RANGE 
    SIGNAL out_index : INTEGER;
    SIGNAL out_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL in_buff_size : INTEGER;
    SIGNAL out_buff_size : INTEGER;

    -- INTERNAL SIGNALS
    SIGNAL curr_buffer : INTEGER := 0;


    -- THIS IS WHERE YOU PUT YOUR BUFFERS
    -- AFTER EVERY GIVEN ONE TACT SIGNAL 'DONE' THE NEXT BUFFER IS LOADED
    SIGNAL buffer_array : memory_bank (0 to BUFFER_NUM-1) := (
        0 => (0 => X"0A", 1 => X"00"),  
        1 => (0 => X"0B", 1 => X"00"),  
        2 => (0 => X"03", 1 => X"00"),  
        3 => (0 => X"04", 1 => X"00"),
        4 => (0 => X"05", 1 => X"00"),  
        5 => (0 => X"05", 1 => X"00")  
    );
    
BEGIN

    project_cmp : project_io PORT MAP (
        clk => clk,
        rst => rst,
        enable => enable,
        done => done,
        in_read_enable => in_read_enable,
        in_index => in_index,
        in_data => in_data,
        out_write_enable => out_write_enable,
        out_index => out_index,
        out_data => out_data,
        in_buff_size => in_buff_size,
        out_buff_size => out_buff_size
    );

    p_clock : PROCESS 
    BEGIN 
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    END PROCESS p_clock;


    process
    begin
        wait for 1000 ns;
        report "end" severity failure;
    end process;

    PROCESS (clk)
    begin
        if rising_edge(clk) then
            if done = '1' then
                enable <= not done;
                
            elsif enable = '0' then
                if curr_buffer = BUFFER_NUM then
                    report "end" severity failure;
                end if;
                in_ram <= buffer_array(curr_buffer);

                curr_buffer <= curr_buffer + 1;

                enable <= '1';
            end if;
        end if;

    end process;
    

    p_ram_reader : PROCESS (clk)
    BEGIN 
        IF rising_edge(clk) AND enable = '1' AND in_read_enable = '1' THEN
            in_data <= in_ram(in_index);
        END IF;
    END PROCESS p_ram_reader;

    p_ram_output : PROCESS (clk)
    variable line_out : line;
    BEGIN 
        IF rising_edge(clk) AND out_write_enable = '1' AND enable = '1' THEN
            
            write (line_out, to_integer(unsigned(out_data)));
            writeline (output, line_out);
        END IF;
    END PROCESS p_ram_output;

    

END architecture behavioural;