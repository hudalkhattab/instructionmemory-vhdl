library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
    generic (
        ADDR_WIDTH : integer := 10;  -- 2^10 = 1024 instruction
        DATA_WIDTH : integer := 32   -- 32-bit instruction
    );
    port (
        clk       : in  std_logic;
        addr      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        instr_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is

    -- Instruction memory array (ROM)
    type rom_type is array (0 to 2**ADDR_WIDTH - 1)
        of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal ROM : rom_type := (
        0 => x"00000013", -- NOP
        1 => x"00100093", -- example instruction
        2 => x"00200113",
        others => (others => '0')
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            instr_out <= ROM(to_integer(unsigned(addr)));
        end if;
    end process;
end Behavioral;

