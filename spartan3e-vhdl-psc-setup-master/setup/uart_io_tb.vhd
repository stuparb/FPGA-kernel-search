LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY uart_io_tb IS
END ENTITY uart_io_tb;

ARCHITECTURE tb OF uart_io_tb IS
    SIGNAL clk_s : STD_LOGIC;
    SIGNAL reset_s : STD_LOGIC;
    SIGNAL input_enable_s : STD_LOGIC;
    SIGNAL output_enable_s : STD_LOGIC;
    SIGNAL input_data_s : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL output_data_s : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL input_empty_s : STD_LOGIC;
    SIGNAL input_empty_next_s : STD_LOGIC;
    SIGNAL output_full_s : STD_LOGIC;
    SIGNAL output_full_next_s : STD_LOGIC;
    -- kontrolni signali??

    SIGNAL tx_dv_s : STD_LOGIC;
    SIGNAL tx_byte_s : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL tx_done_s : STD_LOGIC;
    SIGNAL tx_serial_s : STD_LOGIC;
    SIGNAL tx_active_s : STD_LOGIC;

    SIGNAL rx_serial_s : STD_LOGIC;
    SIGNAL rx_dv_s : STD_LOGIC;
    SIGNAL rx_byte_s : STD_LOGIC_VECTOR (7 DOWNTO 0);

    constant clk_period : time := 20 ns;
BEGIN

    uut : ENTITY work.uart_io
        PORT MAP(
            clk => clk_s,
            reset => reset_s,
            rx => tx_serial_s,
            tx => rx_serial_s,
            input_enable => input_enable_s,
            output_enable => output_enable_s,
            input_data => input_data_s,
            output_data => output_data_s,
            input_empty => input_empty_s,
            input_empty_next => input_empty_next_s,
            output_full => output_full_s,
            output_full_next => output_full_next_s
        );

    u_tx : ENTITY work.uart_tx
        PORT MAP(
            i_Clk => clk_s,
            i_TX_DV => tx_dv_s,
            i_TX_Byte => tx_byte_s,
            o_TX_Active => tx_active_s,
            o_TX_Serial => tx_serial_s,
            o_TX_Done => tx_done_s
        );

    u_rx : ENTITY work.uart_rx
        PORT MAP(
            i_Clk => clk_s,
            i_RX_Serial => rx_serial_s,
            o_RX_DV => rx_dv_s,
            o_RX_Byte => rx_byte_s
        );
    clock_gen : PROCESS BEGIN
        clk_s <= '0';
        WAIT FOR clk_period/2;
        clk_s <= '1';
        WAIT FOR clk_period/2;
    END PROCESS clock_gen;
    stimulus : PROCESS BEGIN
        tx_byte_s <= "10100101";
        tx_dv_s <= '1';
        WAIT UNTIL rising_edge(tx_done_s);
        input_enable_s <= '1';
        WAIT FOR 20 ns;
        input_enable_s <= '0';
        output_enable_s <= '1';
        output_data_s <= "00111100";
        WAIT ON rx_serial_s;
        WAIT FOR 20 ns;
    END PROCESS stimulus;

END ARCHITECTURE tb;