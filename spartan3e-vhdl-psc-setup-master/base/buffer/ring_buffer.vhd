LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ring_buffer IS
    GENERIC (
        RAM_WIDTH : NATURAL;
        RAM_DEPTH : NATURAL
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        -- Write port
        wr_en : IN STD_LOGIC;
        wr_data : IN STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);

        -- Read port
        rd_en : IN STD_LOGIC;
        rd_valid : OUT STD_LOGIC;
        rd_data : OUT STD_LOGIC_VECTOR(RAM_WIDTH - 1 DOWNTO 0);

        -- Flags
        empty : OUT STD_LOGIC;
        empty_next : OUT STD_LOGIC;
        full : OUT STD_LOGIC;
        full_next : OUT STD_LOGIC;

        -- The number of elements in the FIFO
        fill_count : OUT INTEGER RANGE RAM_DEPTH - 1 DOWNTO 0
    );
END ring_buffer;

ARCHITECTURE rtl OF ring_buffer IS

    TYPE ram_type IS ARRAY (0 TO RAM_DEPTH - 1) OF
    STD_LOGIC_VECTOR(wr_data'RANGE);
    SIGNAL ram : ram_type;

    SUBTYPE index_type IS INTEGER RANGE ram_type'RANGE;
    SIGNAL head : index_type;
    SIGNAL tail : index_type;

    SIGNAL empty_i : STD_LOGIC;
    SIGNAL full_i : STD_LOGIC;
    SIGNAL fill_count_i : INTEGER RANGE RAM_DEPTH - 1 DOWNTO 0;

    -- Increment and wrap
    PROCEDURE incr(SIGNAL index : INOUT index_type) IS
    BEGIN
        IF index = index_type'high THEN
            index <= index_type'low;
        ELSE
            index <= index + 1;
        END IF;
    END PROCEDURE;

BEGIN

    -- Copy internal signals to output
    empty <= empty_i;
    full <= full_i;
    fill_count <= fill_count_i;

    -- Set the flags
    empty_i <= '1' WHEN fill_count_i = 0 ELSE
        '0';
    empty_next <= '1' WHEN fill_count_i <= 1 ELSE
        '0';
    full_i <= '1' WHEN fill_count_i >= RAM_DEPTH - 1 ELSE
        '0';
    full_next <= '1' WHEN fill_count_i >= RAM_DEPTH - 2 ELSE
        '0';

    -- Update the head pointer in write
    PROC_HEAD : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                head <= 0;
            ELSE

                IF wr_en = '1' AND full_i = '0' THEN
                    incr(head);
                END IF;

            END IF;
        END IF;
    END PROCESS;

    -- Update the tail pointer on read and pulse valid
    PROC_TAIL : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                tail <= 0;
                rd_valid <= '0';
            ELSE
                rd_valid <= '0';

                IF rd_en = '1' AND empty_i = '0' THEN
                    incr(tail);
                    rd_valid <= '1';
                END IF;

            END IF;
        END IF;
    END PROCESS;

    -- Write to and read from the RAM
    PROC_RAM : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            ram(head) <= wr_data;
            rd_data <= ram(tail);
        END IF;
    END PROCESS;

    -- Update the fill count
    PROC_COUNT : PROCESS (head, tail)
    BEGIN
        IF head < tail THEN
            fill_count_i <= head - tail + RAM_DEPTH;
        ELSE
            fill_count_i <= head - tail;
        END IF;
    END PROCESS;

END ARCHITECTURE;