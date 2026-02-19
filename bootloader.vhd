library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bootloader is
generic(
    PROGRAM_SIZE : integer := 256
);
port(

    clk : in std_logic;
    rst : in std_logic;

    -- ROM READ MASTER
    rom_araddr  : out std_logic_vector(31 downto 0);
    rom_arvalid : out std_logic;
    rom_rdata   : in  std_logic_vector(31 downto 0);
    rom_rvalid  : in  std_logic;
    rom_rready  : out std_logic;

    -- RAM WRITE MASTER
    ram_awaddr  : out std_logic_vector(31 downto 0);
    ram_wdata   : out std_logic_vector(31 downto 0);
    ram_wvalid  : out std_logic;
    ram_bvalid  : in  std_logic;
    ram_bready  : out std_logic;

    -- CPU start signal
    cpu_ready : out std_logic
);
end bootloader;

architecture Behavioral of bootloader is

type state_type is (
    IDLE,
    READ_REQ,
    READ_WAIT,
    WRITE_REQ,
    WRITE_WAIT,
    DONE
);

signal state : state_type := IDLE;

signal addr_cnt : integer range 0 to PROGRAM_SIZE := 0;
signal data_buf : std_logic_vector(31 downto 0) := (others => '0');

begin

process(clk)
begin
if rising_edge(clk) then

    if rst = '1' then

        state <= IDLE;
        addr_cnt <= 0;
        cpu_ready <= '0';

        rom_arvalid <= '0';
        rom_rready  <= '0';

        ram_wvalid <= '0';
        ram_bready <= '0';

    else

        case state is

       
        when IDLE =>
    
            addr_cnt <= 0;
            cpu_ready <= '0';
            state <= READ_REQ;

       
        when READ_REQ =>
   
            rom_araddr  <= std_logic_vector(to_unsigned(addr_cnt*4,32));
            rom_arvalid <= '1';
            rom_rready  <= '1';
            state <= READ_WAIT;

        
        when READ_WAIT =>
        
            if rom_rvalid = '1' then
                data_buf <= rom_rdata;
                rom_arvalid <= '0';
                rom_rready  <= '0';
                state <= WRITE_REQ;
            end if;

       
        when WRITE_REQ =>
      
            ram_awaddr <= std_logic_vector(to_unsigned(addr_cnt*4,32));
            ram_wdata  <= data_buf;
            ram_wvalid <= '1';
            ram_bready <= '1';
            state <= WRITE_WAIT;

       
        when WRITE_WAIT =>
    
            if ram_bvalid = '1' then

                ram_wvalid <= '0';
                ram_bready <= '0';

                if addr_cnt = PROGRAM_SIZE-1 then
                    state <= DONE;
                else
                    addr_cnt <= addr_cnt + 1;
                    state <= READ_REQ;
                end if;

            end if;

        
        when DONE =>
      
            cpu_ready <= '1';

        end case;

    end if;
end if;
end process;

end Behavioral;

