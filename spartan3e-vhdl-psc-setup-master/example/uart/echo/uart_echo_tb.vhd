LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY uart_echo_tb IS
END uart_echo_tb;

ARCHITECTURE behavior OF uart_echo_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT uart_io
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            rx : IN STD_LOGIC;
            tx : OUT STD_LOGIC
        );
    END COMPONENT;

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
            o_TX_Done : OUT STD_LOGIC
        );
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
    --Inputs
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL rx : STD_LOGIC := '0';

    --Outputs
    SIGNAL tx : STD_LOGIC;

    SIGNAL in_enable_s : STD_LOGIC := '0';
    SIGNAL in_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL tx_active : STD_LOGIC := '0';
    SIGNAL tx_done : STD_LOGIC := '0';
    SIGNAL out_enable_s : STD_LOGIC := '0';
    SIGNAL out_data_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";

    -- Clock period definitions
    CONSTANT clk_period : TIME := 20 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : uart_io PORT MAP(
        clk => clk,
        reset => reset,
        rx => rx,
        tx => tx
    );

    utx : uart_tx PORT MAP(
        i_Clk => clk,
        i_TX_DV => in_enable_s,
        i_TX_Byte => in_data_s,
        o_TX_Active => tx_active,
        o_TX_Serial => rx,
        o_TX_Done => tx_done
    );

    urx : uart_rx
    PORT MAP(
        i_Clk => clk,
        i_RX_Serial => tx,
        o_RX_DV => out_enable_s,
        o_RX_Byte => out_data_s
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;
    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        WAIT FOR 100 ns;
        in_enable_s <= '1';
        in_data_s <= x"3F";
        WAIT FOR clk_period * 10;
        in_enable_s <= '0';
        in_data_s <= x"00";

        -- insert stimulus here 

        WAIT;
    END PROCESS;

END;