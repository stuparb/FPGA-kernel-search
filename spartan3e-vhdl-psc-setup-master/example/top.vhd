LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY top IS
    GENERIC (
        IN_RAM_WIDTH : NATURAL := 1500;
        OUT_RAM_WIDTH : NATURAL := 1500
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        rx : IN STD_LOGIC;
        tx : OUT STD_LOGIC
    );
END ENTITY top;
ARCHITECTURE behavioural OF top IS

    COMPONENT uart_io IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            rx : IN STD_LOGIC;
            tx : OUT STD_LOGIC;
            input_enable : IN STD_LOGIC;
            output_enable : IN STD_LOGIC;
            input_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            output_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            input_empty : OUT STD_LOGIC;
            input_empty_next : OUT STD_LOGIC;
            output_full : OUT STD_LOGIC;
            output_full_next : OUT STD_LOGIC
            --input_fill_count : OUT INTEGER RANGE 0 TO 255
            --output_fill_count : OUT INTEGER RANGE 0 TO 255
        );
    END COMPONENT uart_io;

    SIGNAL input_enable_s : STD_LOGIC := '0';
    SIGNAL output_enable_s : STD_LOGIC := '0';
    SIGNAL input_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL output_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rx_buff_empty_s : STD_LOGIC := '0';
    SIGNAL rx_buff_empty_next_s : STD_LOGIC := '0';
    SIGNAL tx_buff_full_s : STD_LOGIC := '0';
    SIGNAL tx_buff_full_next_s : STD_LOGIC := '0';

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
            out_buff_size : OUT INTEGER
        );
    END COMPONENT project_io;

    SIGNAL pr_enable_s : STD_LOGIC;
    SIGNAL pr_done_s : STD_LOGIC;
    SIGNAL pr_in_read_enable_s : STD_LOGIC;
    SIGNAL pr_in_index_s : INTEGER;
    SIGNAL pr_in_data_s : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL pr_out_write_enable_s : STD_LOGIC;
    SIGNAL pr_out_index_s : INTEGER;
    SIGNAL pr_out_data_s : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL pr_in_buff_size_s : INTEGER;
    SIGNAL pr_out_buff_size_s : INTEGER;

    SIGNAL in_counter_s : INTEGER := 0;
    SIGNAL out_counter_s : INTEGER := 0;
    SIGNAL out_ram_clear_s : STD_LOGIC := '1';
    SIGNAL in_ram_full_s : STD_LOGIC := '0';

    TYPE in_ram_t IS ARRAY (0 TO IN_RAM_WIDTH - 1) OF STD_LOGIC_VECTOR(input_data_s'RANGE);
    SIGNAL in_ram_s : in_ram_t;
    TYPE out_ram_t IS ARRAY (0 TO OUT_RAM_WIDTH - 1) OF STD_LOGIC_VECTOR(output_data_s'RANGE);
    SIGNAL out_ram_s : out_ram_t;

BEGIN

    uart : uart_io PORT MAP(
        clk => clk,
        reset => reset,
        rx => rx,
        tx => tx,
        input_enable => input_enable_s,
        output_enable => output_enable_s,
        input_data => input_data_s,
        output_data => output_data_s,
        input_empty => rx_buff_empty_s,
        input_empty_next => rx_buff_empty_next_s,
        output_full => tx_buff_full_s,
        output_full_next => tx_buff_full_next_s
    );

    project : project_io PORT MAP(
        clk => clk,
        rst => reset,
        enable => pr_enable_s,
        done => pr_done_s,
        in_read_enable => pr_in_read_enable_s,
        in_index => pr_in_index_s,
        in_data => pr_in_data_s,
        out_write_enable => pr_out_write_enable_s,
        out_index => pr_out_index_s,
        out_data => pr_out_data_s,
        in_buff_size => pr_in_buff_size_s,
        out_buff_size => pr_out_buff_size_s
    );

    project_write : PROCESS (clk, reset) BEGIN
        IF rising_edge(clk) THEN
            IF pr_enable_s = '1' AND pr_out_write_enable_s = '1' THEN
                out_ram_s(pr_out_index_s) <= pr_out_data_s;
            END IF;
        END IF;
    END PROCESS;

    project_read : PROCESS (clk, reset) BEGIN
        IF rising_edge(clk) THEN
            IF pr_enable_s = '1' AND pr_in_read_enable_s = '1' THEN
                pr_in_data_s <= in_ram_s(pr_in_index_s);
            END IF;
        END IF;
    END PROCESS;

    uart_write : PROCESS (clk, reset) BEGIN
        IF rising_edge(clk) THEN
            IF pr_enable_s = '0' THEN
                IF out_counter_s /= pr_out_buff_size_s THEN
                    -- upisati u uart tx buffer
                    output_data_s <= out_ram_s(out_counter_s);
                    output_enable_s <= '1';
                    out_counter_s <= out_counter_s + 1;
                ELSE
                    out_ram_clear_s <= '1';
                    output_enable_s <= '0';
                    out_counter_s <= 0;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    uart_read : PROCESS (clk, reset) BEGIN
        IF rising_edge(clk) THEN
            IF pr_enable_s = '0' THEN
                IF in_counter_s /= pr_in_buff_size_s THEN
                    in_ram_s(in_counter_s) <= input_data_s;
                    input_enable_s <= '1';
                    in_counter_s <= in_counter_s + 1;
                ELSE
                    in_ram_full_s <= '1';
                    input_enable_s <= '0';
                    in_counter_s <= 0;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk) BEGIN
        IF rising_edge(clk) THEN
            IF pr_done_s = '1' AND pr_enable_s = '1' THEN
                pr_enable_s <= '0';
            ELSIF pr_enable_s = '0' AND out_ram_clear_s = '1' AND in_ram_full_s = '1' THEN
                pr_enable_s <= '1';
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE behavioural;