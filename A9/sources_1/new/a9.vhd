----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.05.2022 15:25:45
-- Design Name: 
-- Module Name: a9 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_unsigned.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity a9 is
 Port ( input_switch : in std_logic_vector(7 downto 0);
        btn_r : in std_logic;
        btn_w : in std_logic;
        clk : in std_logic; --define a clock
        anode : out std_logic_vector(3 downto 0); -- define a vector for anodes
        segment : out std_logic_vector(6 downto 0); -- define a vector for seven segment display
        led_e : out std_logic; -- define a empty button
        led_f : out std_logic); -- define a full button
end a9;

architecture Behavioral of a9 is
-- import a component of  BRAM
    component BRAM is
        port (
          BRAM_PORTA_addr : in STD_LOGIC_VECTOR ( 12 downto 0 );
          BRAM_PORTA_clk : in STD_LOGIC;
          BRAM_PORTA_din : in STD_LOGIC_VECTOR ( 7 downto 0 );
          BRAM_PORTA_dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
          BRAM_PORTA_en : in STD_LOGIC;
          BRAM_PORTA_we : in STD_LOGIC_VECTOR ( 0 to 0 )
        );
        end component BRAM;

    signal addr :  STD_LOGIC_VECTOR ( 12 downto 0 ); -- define a address of vector size 13
    signal din :  STD_LOGIC_VECTOR ( 7 downto 0 ); -- define a data in of vector size 8
    signal dout : STD_LOGIC_VECTOR ( 7 downto 0 ); -- define a data out of vector size 8
    signal en :  STD_LOGIC;
    signal we :  STD_LOGIC_VECTOR ( 0 to 0 ); -- define a vector of size 0

    --define a FSM states for the read adn write the data
    type states is (idle, write_fifo, read_fifo,read_en);
    signal curr_state : states := idle; -- define current state as idle
    signal depth_counter : integer range 0 to 10:=0; -- define a depth counter for read and write data
    signal full_sig : std_logic:='0'; -- define a signal for full the queue
    signal emp_sig : std_logic := '1'; -- define a signal for empty queue
    signal head_addr : std_logic_vector(3 downto 0):="0000"; -- define a head address  of vector size 4
    signal tail_addr : std_logic_vector(3 downto 0):="0000"; -- define a tail address of vector size of 4
    signal btn_w_sig : std_logic := '0'; -- define a button of write as 0
    signal btn_r_sig : std_logic := '0'; -- define a button for read as 0
    signal prev_w : std_logic := '0'; -- define a prev write as 0
    signal prev_r : std_logic := '0'; -- define a  read as 0
    signal count : integer := 0; -- define a count
    
    signal debouncer_clk : std_logic := '0'; -- define a debounce clk of 0
    signal debouncer_counter : std_logic_vector(20 downto 0):="000000000000000000000"; -- define a debounce counter as a vector of size 21
    signal debouncer_wait : std_logic := '0'; -- define a bit for the deboumce wait
    
    signal output_val : std_logic_vector(7 downto 0):= "00000000"; -- define a output val as a vector of size 8

    signal Bt:std_logic_vector(3 downto 0):="0000"; -- define a button
    signal clk_input:std_logic:='0'; -- define a clock input
    signal refresh_clk :std_logic_vector(19 downto 0):=(others => '0');-- define  a refresh clock

begin
  bram_fifo: component BRAM
  port map (
   BRAM_PORTA_addr => addr,
   BRAM_PORTA_clk => clk,
   BRAM_PORTA_din => din,
   BRAM_PORTA_dout => dout,
   BRAM_PORTA_en => en,
   BRAM_PORTA_we => we
 );

--process over the ridging edge for increase the debounce couounter
process(clk)
begin
  if rising_edge(clk) then
    if debouncer_counter = "111101000010010000000" then
      debouncer_clk <= not debouncer_clk; -- taking negation of the debounce clklk
      debouncer_counter <= "000000000000000000000"; -- assign zero to the debounce counter
    else
      debouncer_counter <= debouncer_counter + '1';  -- add one to gthe debounce counter
    end if ;
  end if ;
end process;

process(debouncer_clk)
begin
    if rising_edge(debouncer_clk) then
        if btn_w = '1' then
            btn_w_sig <= '1'; -- assign 1 to the wrute button
        else
            btn_w_sig <= '0'; -- when write button is not on assign it to zero
        end if ;

        if btn_r = '1' then
            btn_r_sig <= '1';-- when read button is on then assign the read signal to the 1
        else
            btn_r_sig <= '0'; -- when the read button is off then assign the read signal to zero
        end if ;
    end if ;
end process;

-- define a process for display the output in the seven segment display

process(Bt)
begin
segment(0) <= (not Bt(3) and not Bt(2) and not Bt(1) and Bt(0)) or(not Bt(3) and Bt(2) and not Bt(1) and not Bt(0)) or (Bt(3) and Bt(2) and not Bt(1) and Bt(0)) or (Bt(3) and not Bt(2) and Bt(1) and Bt(0));
segment(1) <= (Bt(2) and Bt(1) and not Bt(0)) or (Bt(3) and Bt(1) and Bt(0)) or (not Bt(3) and Bt(2) and not Bt(1) and Bt(0)) or (Bt(3) and Bt(2) and not Bt(1) and not Bt(0));
segment(2) <= ((NOT Bt(3)) AND (NOT Bt(2)) AND Bt(1) AND (NOT Bt(0))) OR (Bt(3) AND Bt(2) AND Bt(1)) OR (Bt(3) AND Bt(2) AND (NOT Bt(0)));
segment(3) <= ((NOT Bt(3)) AND (NOT Bt(2)) AND (NOT Bt(1)) AND Bt(0)) OR ((NOT Bt(3)) AND Bt(2) AND (NOT Bt(1)) AND (NOT Bt(0))) OR (Bt(3) AND (NOT Bt(2)) AND Bt(1) AND (NOT Bt(0))) OR (Bt(2) AND Bt(1) AND Bt(0));
segment(4) <= ((NOT Bt(2)) AND (NOT Bt(1)) AND Bt(0)) OR ((NOT Bt(3)) AND Bt(0)) OR ((NOT Bt(3)) AND Bt(2) AND (NOT Bt(1)));
segment(5) <= ((NOT Bt(3)) AND (NOT Bt(2)) AND Bt(0)) OR ((NOT Bt(3)) AND (NOT Bt(2)) AND (Bt(1))) OR ((NOT Bt(3)) AND Bt(1) AND Bt(0)) OR (Bt(3) AND Bt(2) AND (NOT Bt(1)) AND Bt(0));
segment(6) <= ((NOT Bt(3)) AND (NOT Bt(2)) AND (NOT Bt(1))) OR ((NOT Bt(3)) AND Bt(2) AND Bt(1) AND Bt(0)) OR (Bt(3) AND Bt(2) AND (NOT Bt(1)) AND (NOT Bt(0)));

end process;

--define a process over the ridging edge for increase the refresh clk counter
process(clk)
begin 
if rising_edge(clk) then
    refresh_clk <= refresh_clk + '1';
    end if ;
end process;

clk_input <= refresh_clk(19);

-- define a process over the clock input for glowing the the 4 anodes according to their conditions
process(clk_input)
begin
case( clk_input ) is

    when '0' =>
        anode <= "1110";
        Bt <= output_val(3 downto 0);

    when '1' =>
        anode <= "1101";
        Bt <= output_val(7 downto 4);
    when others => anode <= "1111";

end case ;
end process;

process(clk)
begin
  if rising_edge(clk) then
    case( curr_state ) is
    -- if state is idle
      when idle =>
        -- if depth_counter = 0 then
        --   emp_sig <= '1';
        --   full_sig <= '0';
          
        -- elsif depth_counter = 10 then
        --   emp_sig <= '0';
        --   full_sig <= '1';
          
        -- else
        --   emp_sig <= '0';
        --   full_sig <= '0';
          
        -- end if ;
        en<='0';
        we <= "0";
        debouncer_wait <= '0';
        -- if button r sign is 1  then go to read_fifo and prev_r = 0 
        if btn_r_sig = '1' and prev_r = '0' then
          en <= '1';
          we <= "0";
          debouncer_wait <= '1';
          curr_state<=read_fifo;
        elsif btn_w_sig = '1' and prev_w = '0' then 
        -- if button w sign is 1  then go to write_fifo and prev_w = 0 
          en <= '1';
          we <= "1";
          debouncer_wait <= '1';
          curr_state<=write_fifo;
        else
          curr_state<=idle;
        end if ;
      
        --if state is write fifo then write in the queue
      when write_fifo =>
        if debouncer_wait <= '1' then 
          if depth_counter < 10 then
            addr <= "000000000" & head_addr(3 downto 0);
            depth_counter <= depth_counter + 1;
            din <= input_switch;
            if head_addr = "1010" then
              head_addr <= "0000";
            else
              head_addr <= head_addr + 1;
            end if ;
            debouncer_wait <= '0';
            curr_state<= idle;
          else
            curr_state<=idle;
          end if ;

        else
          debouncer_wait <= '1';
          curr_state <= idle;
        end if;
  
      -- if state is read fifo then read the data 
      when read_fifo =>
        if debouncer_wait <= '1' then 
          -- debouncer_wait <= '0';
          if depth_counter > 0 then
            -- depth_counter <= depth_counter - 1;
            -- addr <= addr(12 downto 4) & tail_addr;
            addr <= "000000000" & tail_addr(3 downto 0);
            if tail_addr = "1010" then
              tail_addr <= "0000";
            else
              tail_addr <= tail_addr + 1;
            end if ;
            depth_counter <= depth_counter - 1;
            debouncer_wait <= '0';
            -- output_val <= dout;
            count <= 1;
            curr_state <= read_en;
          else
            curr_state <= idle;
          end if ;
          -- curr_state <= idle; for else
        else
          debouncer_wait <= '1';
          curr_state <= idle;
        end if;
      when read_en =>
        if count < 3  then
            count<= count +1;
        elsif count = 3 then
            output_val <= dout;
            curr_state <= idle;
            en <= '0';
            we <= "0";
        end if ;
      when others =>
        curr_state<=idle;
    end case ;
    prev_w <= btn_w_sig;
    prev_r <= btn_r_sig;
  end if ;
end process;

-- if process is clk over the rising edge
process(clk)
begin
  if rising_edge(clk) then
    -- if counter is zero then set led empty as 0
    if depth_counter = 0 then
      led_e <= '1';
    else
      led_e <= '0';
    end if ;

    if depth_counter = 10 then
      led_f <= '1';
    else
      led_f <= '0';
    end if ;
  end if ;
end process;

end Behavioral;
