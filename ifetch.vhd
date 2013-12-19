--
--
-- Ifetch module (provides the PC and instruction memory for the SPIM computer)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

--library SYNTH;
--use SYNTH.VHDLSYNTH.ALL;
--use SYNTH.VIEWARCHITECT.ALL;
--use SYNTH.VL_COMPS.ALL;

entity Ifetch is
generic (
			datapath_size : integer;
			word_size : integer;
			imem_size : integer
			);
port( 
			Instruction : out std_logic_vector(word_size - 1 downto 0);
         PCadd : out  std_logic_vector(datapath_size - 1 downto 0);
         Addresult : in std_logic_vector(datapath_size - 1 downto 0);
         Branch : in std_logic;
			BranchNotEqual: in std_logic;
			Jump: in std_logic;
			JR:   in std_logic;
         phi2, reset : in std_logic;
         Zero : in std_logic);

end Ifetch;

--
-- Ifetch architecture
--

architecture behavior of Ifetch is

	signal PC : std_logic_vector(datapath_size - 1 downto 0) := conv_std_logic_vector(0,datapath_size);
	signal PCtemp : std_logic_vector(datapath_size - 1 downto 0) := conv_std_logic_vector(0,datapath_size);
	signal PCaddtemp : std_logic_vector(datapath_size - 1 downto 0) := conv_std_logic_vector(0,datapath_size);
	signal imemContent: std_logic_vector(word_size - 1 downto 0);
	
	-- Insert SPIM Machine Language Test Program Here

	type memory_array is array (0 to 2**imem_size - 1) of std_logic_vector(word_size - 1 downto 0);
	constant imem : memory_array := (
-- place your machine code here:
-- include assembly code as comments

       X"3410c000",     --      8: ori $s0, $zero, 0xC000
     X"34090055",     --      9: ori $t1, $zero, 0x55
     X"ae090008",     --      11: sw $t1, 8($s0)
     X"340b0096",     --      12: ori $t3, $zero, 150
     X"216bffff",     --      14: addi $t3, $t3, -1
     X"8e090000",     --      17: lw $t1, 0($s0) ## inner loop 65,535 x 5 =
     X"214a0001",     --      18: addi $t2, $t2, 1
     X"31290100",     --      19: andi $t1, $t1, 0x100
     X"1520000d",     --     
     X"1540fffb",     --     
     X"1560fff9",     --     
     X"340900aa",     --      24: ori $t1, $zero, 0xAA
     X"ae090008",     --      26: sw $t1, 8($s0)
     X"340b0096",     --      27: ori $t3, $zero, 150
     X"216bffff",     --      29: addi $t3, $t3, -1
     X"8e090000",     --      32: lw $t1, 0($s0) ## inner loop 65,535 x 5 =
     X"214a0001",     --      33: addi $t2, $t2, 1
     X"31290100",     --      34: andi $t1, $t1, 0x100
     X"15200003",     --     
     X"1540fffb",     --     
     X"1560fff9",     --     
     X"1000ffea",     --     
     X"8e090000",     --      42: lw $t1, 0($s0) ## loop to wait while button is pressed.
     X"31290100",     --      43: andi $t1, $t1, 0x100
     X"1520fffd",     --     
     X"1000ffe6",     --     

		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000"),
		(x"00000000"),	(x"00000000"),	(x"00000000"),	(x"00000000")

		);
	


	begin
-- Increment PC by 4        
--		PCout <= PC;
      PCaddtemp(datapath_size - 1 downto 2) <= PC(datapath_size - 1 downto 2) + 1;
		PCaddtemp(1 downto 0) <= "00";
      PCadd <= PCaddtemp(datapath_size - 1 downto 0);  
		
-- Mux for Branch Address or Next Address        
		PCtemp <= Addresult WHEN (((Branch='1') AND (Zero='1')) OR ((BranchNotEqual='1') AND (Zero='0')) OR (JR='1'))
				   ELSE imemContent(datapath_size - 3 downto 0) & "00" WHEN Jump = '1'
					ELSE PCaddtemp(datapath_size - 1 downto 0);
-- Load next PC
		PROCESS (phi2)
        Begin
        if (phi2'event) and (phi2='1') then
				If reset='1' then
					PC<=(conv_std_logic_vector(0,datapath_size));
					else PC<=PCtemp;
				end if;
		  end if;
        end process;

-- Fetch Instruction from memory     
      Process (PC)
          begin
 				imemContent <= imem(conv_integer(PC(imem_size + 1 downto 2)));
			 end process;
	instruction <= imemContent;
end behavior;

