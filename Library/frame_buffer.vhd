-- create a buffer to store pixels data for a frame of 320x240 pixels;
-- data for each pixel is 12 bits;
-- that is 76800 pixels; hence, address is represented on 17 bits 
-- (2^17 = 131072 > 76800);
-- Notes: 
-- 1) If we wanted to work with 640x480 pixels, that would require
-- an amount of embedded RAM that is not available on the Cyclone IV E of DE2-115;
-- 2) We create the buffer with 76800 by stacking-up two blocks
-- of 2^16 = 65536 addresses; 

LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY frame_buffer IS
  PORT
  (
    data : IN std_logic_vector(11 downto 0);
    rdaddress : IN std_logic_vector(16 downto 0);
    rdclock : IN std_logic;
    wraddress : IN std_logic_vector(16 downto 0);
    wrclock : IN std_logic;
    wren : IN std_logic;          
    q : OUT std_logic_vector(11 downto 0)
  );
END frame_buffer;


ARCHITECTURE SYN OF frame_buffer IS

  
  COMPONENT my_frame_buffer_15to0 IS
  PORT
  (
    data : IN std_logic_vector(11 downto 0);
    rdaddress : IN std_logic_vector(15 downto 0);
    rdclock : IN std_logic;
    wraddress : IN std_logic_vector(15 downto 0);
    wrclock : IN std_logic;
    wren : IN std_logic;          
    q : OUT std_logic_vector(11 downto 0)
  );
  END COMPONENT;

  
  -- read signals
  signal q_top : STD_LOGIC_VECTOR (11 DOWNTO 0);
  signal q_bottom : STD_LOGIC_VECTOR (11 DOWNTO 0);
  -- write signals
  signal wren_top : STD_LOGIC;
  signal wren_bottom : STD_LOGIC;
  
BEGIN

  Inst_buffer_top : my_frame_buffer_15to0
    PORT MAP (
      data => data(11 downto 0),
      rdaddress => rdaddress(15 downto 0),
      rdclock => rdclock,
      wraddress => wraddress(15 downto 0),
      wrclock => wrclock,
      wren => wren_top,
      q => q_top
    );
  Inst_buffer_bottom : my_frame_buffer_15to0
    PORT MAP (
      data => data(11 downto 0),
      rdaddress => rdaddress(15 downto 0),
      rdclock => rdclock,
      wraddress => wraddress(15 downto 0),
      wrclock => wrclock,
      wren => wren_bottom,
      q => q_bottom
    );  
    
  process (wraddress(16), wren)
  begin
    case wraddress(16) is 
      when '0' =>
        wren_top <= wren; wren_bottom <= '0';
      when '1' =>
        wren_top <= '0'; wren_bottom <= wren;  
      when others =>
        wren_top <= '0'; wren_bottom <= '0';
    end case;
  end process;
  
  process (rdaddress(16), q_top, q_bottom)
  begin
    case rdaddress(16) is 
      when '0' =>
        q <= q_top;
      when '1' =>
        q <= q_bottom;
      when others =>
        q <= "000000000000";
    end case;
  end process;
    
END SYN;