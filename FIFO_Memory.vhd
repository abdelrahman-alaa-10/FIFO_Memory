library ieee;
use ieee.std_logic_1164.all; -- Standard Logic Package
use ieee.numeric_std.all; -- Numeric Standard Package

-- Define the FIFO Memory entity (4x2)
entity FIFO_Memory is
    Port (
        Input_Bus : in std_logic_vector ( 1 downto 0); -- Input bus for data
        CLK : in std_logic ; -- Clock signal
        RST : in std_logic; -- Reset signal
        WRT : in std_logic; -- Write enable signal
        READ_EN : in std_logic; -- Read enable signal
        EN : in std_logic; -- Overall enable signal
        --WARN : out std_logic ; -- Warning signal for full or empty memory
        Output_Bus : out std_logic_vector (1 downto 0) -- Output bus for data
    );
end FIFO_Memory;

-- Define the architecture for the FIFO Memory
architecture mem_arch of FIFO_Memory is
    signal WRITER , READER: std_logic_vector (1 downto 0); -- Writer and Reader pointers
    type FIFO_TRAIN is array (3 downto 0) of std_logic_vector (1 downto 0); -- Define the memory type
    signal MEMORY:FIFO_TRAIN; -- Memory signal
begin
    -- Define the process sensitive to Clock and Reset
    process (CLK , RST)
    begin
        -- If Reset is high, initialize the Writer and Reader pointers and Warning signal
        if RST ='1' then 
            WRITER <="00";
            READER <="00";
            --WARN <= '0';
        -- If rising edge of Clock and Enable is high
        elsif rising_edge(CLK) and EN = '1' then
            --WARN <= '0';
            -- If Write enable is high
            if WRT = '1' then
                -- If Writer pointer is not at the end
                if WRITER < "11" then
                    -- Write data to memory
                    MEMORY(to_integer(unsigned(WRITER))) <= Input_Bus;
                    -- If Writer pointer is at the second last position, wrap around to the start
                    if WRITER = "10" then
                        WRITER <= "00";
                    -- Else increment the Writer pointer
                    else
                        WRITER <= std_logic_vector(unsigned(WRITER) + 1);
                    end if;
                -- If Writer pointer is at the end, set Warning signal and report full memory
                else
                    --WARN <= '1';
                    report "Full Memory";
                end if;
            end if;
            -- If Read enable is high
            if READ_EN = '1' then
                -- If Reader pointer is at the same position as Writer pointer, set Warning signal and report empty memory
                if READER = WRITER then
                    --WARN <= '1';
                    report "Memory is empty";
                -- Else read data from memory
                else
                    Output_Bus <= MEMORY(to_integer(unsigned(READER)));
                    -- If Reader pointer is at the second last position, wrap around to the start
                    if READER = "10" then
                        READER <= "00";
                    -- Else increment the Reader pointer
                    else
                        READER <= std_logic_vector(unsigned(READER) + 1);
                    end if;
                end if;
            end if;
        end if;
    end process;
end mem_arch;

							