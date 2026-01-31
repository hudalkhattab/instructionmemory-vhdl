library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory_tb is
end InstructionMemory_tb;

architecture Behavioral of InstructionMemory_tb is

    constant ADDR_WIDTH : integer := 10;
    constant DATA_WIDTH : integer := 32;

    signal clk       : std_logic := '0';
    signal addr      : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal instr_out : std_logic_vector(DATA_WIDTH-1 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- DUT (Device Under Test)
    UUT: entity work.InstructionMemory
        generic map (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk       => clk,
            addr      => addr,
            instr_out => instr_out
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        addr <= std_logic_vector(to_unsigned(0, ADDR_WIDTH));
        wait for clk_period;

        addr <= std_logic_vector(to_unsigned(1, ADDR_WIDTH));
        wait for clk_period;

        addr <= std_logic_vector(to_unsigned(2, ADDR_WIDTH));
        wait for clk_period;

        addr <= std_logic_vector(to_unsigned(10, ADDR_WIDTH));
        wait for clk_period;

        wait;
    end process;
