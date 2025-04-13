LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_io IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        rx : IN STD_LOGIC;
        tx : OUT STD_LOGIC;
        input_enable : IN STD_LOGIC :='0';
        output_enable : IN STD_LOGIC :='0';
        input_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        output_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0) :=x"00";
        input_empty : OUT STD_LOGIC;
        input_empty_next : OUT STD_LOGIC;
        output_full : OUT STD_LOGIC;
        output_full_next : OUT STD_LOGIC
        --input_fill_count : OUT INTEGER RANGE 0 TO 255
        --output_fill_count : OUT INTEGER RANGE 0 TO 255
    );
END ENTITY uart_io;

ARCHITECTURE behavioural OF uart_io IS

    COMPONENT uart_tx IS
        GENERIC (
            g_CLKS_PER_BIT : INTEGER := 434 -- Needs to be set correctly
        );
        PORT (
            i_Clk : IN STD_LOGIC;
            i_TX_DV : IN STD_LOGIC;
            i_TX_Byte : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_TX_Active : OUT STD_LOGIC;
            o_TX_Serial : OUT STD_LOGIC;
            o_TX_Done : OUT STD_LOGIC);
    END COMPONENT uart_tx;

    COMPONENT uart_rx IS
        GENERIC (
            g_CLKS_PER_BIT : INTEGER := 434 -- Needs to be set correctly
        );
        PORT (
            i_Clk : IN STD_LOGIC;
            i_RX_Serial : IN STD_LOGIC;
            o_RX_DV : OUT STD_LOGIC;
            o_RX_Byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT uart_rx;

    CONSTANT c_CLKS_PER_BIT : INTEGER := 434;

    COMPONENT ring_buffer IS
        GENERIC (
            RAM_WIDTH : INTEGER := 8;
            RAM_DEPTH : INTEGER := 256
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            wr_en : IN STD_LOGIC;
            wr_data : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
            rd_en : IN STD_LOGIC;
            rd_valid : OUT STD_LOGIC;
            rd_data : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);
            empty : OUT STD_LOGIC;
            empty_next : OUT STD_LOGIC;
            full : OUT STD_LOGIC;
            full_next : OUT STD_LOGIC;
            fill_count : OUT INTEGER RANGE RAM_DEPTH - 1 DOWNTO 0
        );
    END COMPONENT ring_buffer;

    SIGNAL uart_rx_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL uart_rx_valid_s : STD_LOGIC := '0';

    SIGNAL input_enable_s : STD_LOGIC := '0';
    SIGNAL able_to_receive_s : STD_LOGIC := '0';
    SIGNAL uart_input_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL input_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rx_buff_full_s : STD_LOGIC := '0';
    SIGNAL rx_buff_empty_s : STD_LOGIC := '0';
    SIGNAL rx_buff_empty_next_s : STD_LOGIC := '0';
    SIGNAL rx_buff_full_next_s : STD_LOGIC := '0';

    SIGNAL uart_tx_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL uart_tx_enable_s : STD_LOGIC := '0';
    SIGNAL uart_tx_busy_s : STD_LOGIC := '0';
    SIGNAL uart_tx_again_available_s : STD_LOGIC := '0';

    SIGNAL able_to_transmit_s : STD_LOGIC := '0';
    SIGNAL output_enable_s : STD_LOGIC := '0';
    SIGNAL output_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL uart_output_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL tx_buff_full_s : STD_LOGIC := '0';
    SIGNAL tx_buff_empty_s : STD_LOGIC := '0';
    SIGNAL tx_buff_empty_next_s : STD_LOGIC := '0';
    SIGNAL tx_buff_full_next_s : STD_LOGIC := '0';

    SIGNAL data_transmission_finished_s : STD_LOGIC := '1';

BEGIN

    rx_0 : uart_rx PORT MAP(
        i_Clk => clk,
        i_RX_Serial => rx,

        o_RX_Byte => uart_rx_data_s,
        o_RX_DV => uart_rx_valid_s);

    rx_buff : ring_buffer PORT MAP(
        clk => clk,
        rst => reset,
        rd_en => input_enable_s,
        wr_en => able_to_receive_s,
        wr_data => uart_input_data_s,

        rd_data => input_data_s,
        full => rx_buff_full_s,
        empty => rx_buff_empty_s,
        empty_next => rx_buff_empty_next_s,
        full_next => rx_buff_full_next_s
    );

    PROCESS (clk) BEGIN
        IF rising_edge(clk) THEN
            IF uart_rx_valid_s = '1' AND rx_buff_full_s = '0' THEN
                able_to_receive_s <= '1';
                uart_input_data_s <= uart_rx_data_s;
            ELSE
                able_to_receive_s <= '0';
                uart_input_data_s <= x"00";
            END IF;
        END IF;
    END PROCESS;

    tx_buff : ring_buffer PORT MAP(
        clk => clk,
        rst => reset,
        rd_en => able_to_transmit_s,
        wr_en => output_enable_s,
        wr_data => output_data_s,

        rd_data => uart_output_data_s,
        full => tx_buff_full_s,
        empty => tx_buff_empty_s,
        empty_next => tx_buff_empty_next_s,
        full_next => tx_buff_full_next_s
    );

    tx_0 : uart_tx PORT MAP(
        i_Clk => clk,
        i_TX_Byte => uart_tx_data_s,
        i_TX_DV => uart_tx_enable_s,

        o_TX_Active => uart_tx_busy_s,
        o_TX_Serial => tx,
        o_TX_Done => uart_tx_again_available_s);

    PROCESS (clk) BEGIN
        IF rising_edge(clk) THEN
            IF data_transmission_finished_s = '1' AND uart_tx_busy_s = '0' AND (tx_buff_empty_s = '0' OR tx_buff_empty_next_s = '1') THEN
                uart_tx_data_s <= uart_output_data_s;
                uart_tx_enable_s <= '1';
                able_to_transmit_s <= '1';
                data_transmission_finished_s <= '0';
            ELSIF data_transmission_finished_s = '0' THEN
                IF uart_tx_again_available_s = '1' THEN
                    data_transmission_finished_s <= '1';
                ELSE
                    data_transmission_finished_s <= '0';
                END IF;
                uart_tx_data_s <= x"00";
                uart_tx_enable_s <= '0';
                able_to_transmit_s <= '0';
            ELSE
                uart_tx_data_s <= x"00";
                uart_tx_enable_s <= '0';
                able_to_transmit_s <= '0';
            END IF;
        END IF;
    END PROCESS;

    process(clk) begin
        if rising_edge(clk) then
            -- input signals
            input_enable_s <= input_enable;
            output_enable_s <= output_enable;
            output_data_s <= output_data;
            
            -- output signals
            input_data <= input_data_s;
            input_empty <= rx_buff_empty_s;
            input_empty_next <= rx_buff_empty_next_s;
            output_full <= tx_buff_full_s;
            output_full_next <= tx_buff_full_next_s;
        end if;
    end process;

END ARCHITECTURE behavioural;
