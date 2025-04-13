LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_echo IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        rx : IN STD_LOGIC;
        tx : OUT STD_LOGIC
    );
END ENTITY uart_echo;


ARCHITECTURE behavioural OF uart_echo IS

    component uart_io is
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

    SIGNAL input_enable_s : STD_LOGIC :='0';
    SIGNAL output_enable_s : STD_LOGIC :='0';
    SIGNAL input_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL output_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rx_buff_empty_s : STD_LOGIC :='0';
    SIGNAL rx_buff_empty_next_s : STD_LOGIC :='0';
    SIGNAL tx_buff_full_s : STD_LOGIC :='0';
    SIGNAL tx_buff_full_next_s : STD_LOGIC :='0';

BEGIN

    io : uart_io PORT MAP (
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

    PROCESS (clk) BEGIN
    IF rising_edge(clk) THEN
        IF (tx_buff_full_s = '0' OR tx_buff_full_next_s = '1') AND (rx_buff_empty_s = '0' OR rx_buff_empty_next_s = '1') THEN
            output_enable_s <= '1';
            input_enable_s <= '1';
            output_data_s <= input_data_s;
        ELSE
            output_enable_s <= '0';
            input_enable_s <= '0';
            output_data_s <= x"00";
        END IF;
    END IF;
    END PROCESS;

end ARCHITECTURE behavioural;