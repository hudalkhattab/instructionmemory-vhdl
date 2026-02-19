library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AXI_BootROM is
    generic (
        C_S_AXI_ADDR_WIDTH : integer := 12; -- 4 KB
        C_S_AXI_DATA_WIDTH : integer := 32
    );
    port (

        -- Global
        S_AXI_ACLK    : in  std_logic;
        S_AXI_ARESETN : in  std_logic;

        -- Read Address Channel
        S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID : in  std_logic;
        S_AXI_ARREADY : out std_logic;

        -- Read Data Channel
        S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP   : out std_logic_vector(1 downto 0);
        S_AXI_RVALID  : out std_logic;
        S_AXI_RREADY  : in  std_logic
    );
end AXI_BootROM;

architecture Behavioral of AXI_BootROM is

    
    -- ROM Tanımı
   
    type rom_type is array (0 to 1023) of std_logic_vector(31 downto 0);

    constant ROM_CONTENT : rom_type := (
        0 => x"00000513",
        1 => x"00100093",
        2 => x"00200113",
        3 => x"00308193",
        others => x"00000013" -- NOP
    );

   
    -- AXI Internal Signals
   
    signal axi_rvalid : std_logic := '0';
    signal axi_rdata  : std_logic_vector(31 downto 0) := (others => '0');

    -- Latched address
    signal latched_addr : integer range 0 to 1023 := 0;

    -- FSM state
    type state_type is (IDLE, READ_DATA);
    signal state : state_type := IDLE;

begin

    
    -- AXI Outputs
    
    S_AXI_ARREADY <= '1';      -- Lite slave always ready
    S_AXI_RVALID  <= axi_rvalid;
    S_AXI_RDATA   <= axi_rdata;
    S_AXI_RRESP   <= "00";     -- OKAY response

    
    -- AXI Read Process
    
    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then

            if S_AXI_ARESETN = '0' then
                axi_rvalid     <= '0';
                axi_rdata      <= (others => '0');
                latched_addr  <= 0;
                state         <= IDLE;

            else

                case state is

                  
                    -- IDLE : Address beklenir
                
                    when IDLE =>

                        if (S_AXI_ARVALID = '1') then

                            -- Address latch
                            if unsigned(S_AXI_ARADDR(11 downto 2)) <= 1023 then
                                latched_addr <=
                                  to_integer(unsigned(S_AXI_ARADDR(11 downto 2)));
                            else
                                latched_addr <= 0;
                            end if;

                            state <= READ_DATA;

                        end if;

                   
                    -- READ_DATA : 1 cycle ROM latency
                  
                    when READ_DATA =>

                        axi_rdata  <= ROM_CONTENT(latched_addr);
                        axi_rvalid <= '1';

                        -- Master veriyi aldıysa
                        if (S_AXI_RREADY = '1') then
                            axi_rvalid <= '0';
                            state <= IDLE;
                        end if;

                end case;

            end if;
        end if;
    end process;

end Behavioral;
