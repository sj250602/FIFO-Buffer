-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (lin64) Build 1756540 Mon Jan 23 19:11:19 MST 2017
-- Date        : Wed May 25 18:13:03 2022
-- Host        : indus running 64-bit Ubuntu 16.04.2 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/btech/cs1190432/a9/a9.srcs/sources_1/bd/BRAM/ip/BRAM_blk_mem_gen_0_0/BRAM_blk_mem_gen_0_0_stub.vhdl
-- Design      : BRAM_blk_mem_gen_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BRAM_blk_mem_gen_0_0 is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 12 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 7 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end BRAM_blk_mem_gen_0_0;

architecture stub of BRAM_blk_mem_gen_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,wea[0:0],addra[12:0],dina[7:0],douta[7:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_3_5,Vivado 2016.4";
begin
end;
