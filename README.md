<p align="center">

	
 ![image](https://github.com/eyemann/pes_wm/assets/142375203/e3e1617e-1bb1-4b31-bbfe-3f9da9cf118d)
</p>


## OBJECTIVE


We will be implementing ASIC design flow through the design of an automatic Washing Machine.
+ RTL Design
+ Synthesis
+ Floorplanning
+ Placement
+ Routing

In a specific automatic washing machine there are usually six states as given above such as, Check door, Fill water, Add detergent, Cycle, Drain water and Spin.



<details>
<summary> INTRODUCTION</summary>
            
.
An automated washing machine, commonly referred to as a washing machine or washer, is a household appliance designed to automate and simplify the process of cleaning and laundering clothing, linens, and other textiles. 
It has become an indispensable part of modern life, offering convenience and efficiency in the task of washing clothes.

+ Loading:

The user loads dirty clothes and other textiles into the washing machine drum. The door is securely closed.

+ Detergent Dispensing:

The user adds detergent or laundry soap to a designated detergent compartment. Some machines have compartments for fabric softener and bleach as well.

+ Water Inlet:

Upon starting the wash cycle, the washing machine's water inlet valve opens, allowing water to flow into the machine. The machine typically adjusts the water temperature according to the user's settings.

+ Agitation and Soaking:

The washing machine's agitator or drum begins to rotate. This motion helps to disperse the detergent, agitate the clothes, and ensure thorough soaking. The duration of this phase depends on the selected wash cycle

+ Draining:

After the soaking and initial agitation, the machine's pump drains the soapy water from the drum into a drainpipe or designated container

+ Rinse Cycle:

The washing machine fills with clean water for the rinsing phase. The machine may perform multiple rinse cycles to ensure all detergent is removed from the clothes.

Here is a state diagram for better understanding:

![image](https://github.com/eyemann/pes_wm/assets/142375203/2d400579-ee8e-4e49-bfa2-6c63c0d07291)
</details>

<details>
<summary> RTL synthesis and GLS simulation: </summary>

	
 <details>
 <summary>Tools required:</summary>

	 
  1) **iverilog** Icarus Verilog or iverilog is an implementation of the Verilog hardware description language.

2) **GTKwave** GTKWave is a fully featured GTK+ v1. 2 based wave viewer for Unix and Win32 which reads Ver Structural Verilog Compiler generated AET files as well as standard Verilog VCD/EVCD files and allows their viewing.
</details>

<details>
<summary>iVerilog and GTKwave</summary>

	
 Systemverilog code for .v file

 ~~~
//`timescale 10ns / 1ps
module pes_wm(clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout, door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash);

	input clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout;
	output reg door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash; 
	
	//defining the states
	parameter check_door = 3'b000;
	parameter fill_water = 3'b001;
	parameter add_detergent = 3'b010;
	parameter cycle = 3'b011;
	parameter drain_water = 3'b100;
	parameter spin = 3'b101;
        
        
	reg[2:0] current_state; 
	reg [2:0] next_state;
	
	always@(*)
	begin
	case(current_state)
		check_door:
			if(start==1 && door_close==1)
			begin
				next_state = fill_water;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 0;
				water_wash = 0;
				done = 0;
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 0;
				soap_wash = 0;
				water_wash = 0;
				done = 0;
			end
			
			fill_water:
			if (filled==1)
			begin
				if(soap_wash == 0)
				begin
					next_state = add_detergent;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 0;
					water_wash = 0;
					done = 0;
				end
				else
				begin
					next_state = cycle;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 1;
				drain_value_on = 0;
				door_lock = 1;
				done = 0;
                                soap_wash = 0;
                                water_wash = 0;
			end
			add_detergent:
			if(detergent_added==1)
			begin
				next_state = cycle;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				done = 0;
                                water_wash = 0;
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 0;
				done = 0;
			end
			cycle:

			if(cycle_timeout == 1)
			begin
				if(water_wash == 0)
				begin
					next_state = drain_water;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 0;
					done = 0;
				end
				else
				begin
					next_state = drain_water;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			else
			begin
				if(water_wash == 0)
				begin
					next_state = current_state;
					motor_on = 1;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 0;
					done = 0;
				end
				else
				begin
					next_state = current_state;
					motor_on = 1;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			drain_water:
			 if(drained==1)
			 begin
				if(water_wash==0)
				begin
					next_state = fill_water;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 0;
					done = 0;
				end
				else
				begin
				        next_state = spin;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 1;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 0;
				done = 0;
			end
			spin:
			if(spin_timeout==1)
			begin
				next_state = door_close;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 1;
				done = 1;
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 1;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 1;
				done = 0;
			end
			default: begin
                                next_state = check_door;
                                motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 0;
				soap_wash = 0;
				water_wash = 0;
				done = 0;
		        end
                                
				
			endcase
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			current_state<=3'b000;
		end
		else
		begin
			current_state<=next_state;
		end
	end
	
endmodule
 ~~~

<img width="538" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/02f00393-9d53-44c4-9b7b-4fd1b638c404">


 Systemverilog code for tb.v file
~~~
module pes_wm_tb();
	reg clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout;
	wire door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash; 
	
	
iiitb_wm machine1(clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout, door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash);


	
	
	initial
		
	begin
	clk = 0;
		reset = 1;
		start = 0;
		door_close = 0;
		filled = 0;
		drained = 0;
		detergent_added = 0;
		cycle_timeout = 0;
		spin_timeout = 0;
		
		#5 reset=0;
		#5 start=1;door_close=1;
		#10 filled=1;
		#10 detergent_added=1;
		//filled=0;
		#10 cycle_timeout=1;
		//detergent_added=0;
		#10 drained=1;
		//cycle_timeout=0;
		#10 spin_timeout=1;
		//drained=0;
		
		/*
		
		#0 reset = 0;
		#2 start = 1;
		#4 door_close = 1;
		#3 filled = 1;
		#3 detergent_added = 1;
		#2 cycle_timeout = 1;
		#2 drained = 1; 
		#3 spin_timeout = 1;
		*/
	end
	
	always
	begin
		#5 clk = ~clk;
	end
	
	initial
	begin
		$monitor("Time=%d, Clock=%b, Reset=%b, start=%b, door_close=%b, filled=%b, detergent_added=%b, cycle_timeout=%b, drained=%b, spin_timeout=%b, door_lock=%b, motor_on=%b, fill_valve_on=%b, drain_valve_on=%b, soap_wash=%b, water_wash=%b, done=%b",$time, clk, reset, start, door_close, filled, detergent_added, cycle_timeout, drained, spin_timeout, door_lock, motor_on, fill_value_on, drain_value_on, soap_wash, water_wash, done);
	end
  initial 
  begin
    $dumpfile("pes_wm_tb.vcd");
    $dumpvars(0,pes_wm_tb);
  end
endmodule
~~~

<img width="529" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/e418d032-a45a-41ed-a951-7df97bc90586">

Pre-synthesis result

<img width="350" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/04a11bde-c4a4-4e5f-a0c1-7c7301e01c73">

<img width="384" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/1d1d48a8-399e-43a1-a68a-5b180da59544">

Now our main file and testbench in systemverilog is ready, we will now run it using `./a.out` which will create dump.vcd

+ `iverilog pes_wm.v pes_wm_tb.v`
+ `ls`
  
<img width="532" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/948084b7-d7e9-4431-bf2c-a2ed74a440b1">

+ `./a.out`
+ `gtkwave dump.vcd`

<img width="434" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/65a4dbe7-0cc6-4a1f-a5e8-dd9875242bfe">


  
<img width="480" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/2361f5de-81fd-44db-bfa2-848c083ef9cc">
</details>
<details>
<summary>RTL SYNTHESIS</summary>

+ `yosys`
+ `read_liberty -lib ../lib/sky130_fd_sc_hd__tt_025C_1v80.lib`
+ `read_verilog pes_wm.v`
+ `synth -top pes_wm`
  

<img width="435" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/06d17de8-1201-4c81-a610-d1ec26ed33f6">

<img width="334" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/3a72071d-b13e-4fb3-9c6d-622f17736531">

+ `abc -liberty -lib ./lib/sky130_fd_sc_hd__tt_025C_1v80.lib
 show`

<img width="600" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/42f7c4ec-65a7-497c-954e-cf0e8f0c61d5">

+ `write_verilog pes_wm.v
!vim pes_wm.v`

<img width="396" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/a81a7194-057c-4c9e-891d-807de382be0b">
<img width="390" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/2b5da2e7-3df4-4f5a-9a01-55872bb3f03e">

To reduce code further, run the command

+ `write_verilog -noattr pes_wm.v`
  
<img width="359" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/e205b096-52a9-4262-9831-9397972f0b99">

</details>
<details>
<summary>Gate Level Simulation</summary>


+ `iverilog ../my_lib/verilog_model/primitives.v ../my_lib/verilog_model/sky130_fd_sc_hd.v pes_wm.v pes_wm_tb.v
ls`

<img width="525" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/e53fada5-3ad3-423d-ab60-06c915ceb768">

+ `./a.out`

<img width="525" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/febd548d-fec1-498e-b95b-3f53fc983e14">
</details>
</details>

<details>
<summary> Physical Design </summary>
<br>
	
<h1> Physical design </h1> is the process of transforming a high-level hardware description of a digital circuit into the actual physical layout that can be fabricated as a semiconductor chip. It involves several key steps and considerations, and here's an overview of the ASIC physical design process:

**Floorplanning:** In this initial step, you create a high-level floorplan that defines the placement of different functional blocks, the core area, and the location of I/O pads. Floorplanning plays a crucial role in determining the chip's overall size, shape, and organization.

**Placement:** During placement, you determine the precise location of individual logic gates, flip-flops, and other components within the core area defined in the floorplan. The goal is to optimize for factors like signal routing, power distribution, and heat dissipation.

**Clock Tree Synthesis (CTS):** Clock tree synthesis involves building an optimized clock distribution network to ensure that clock signals are delivered with minimal skew and jitter to all parts of the chip. Clock domains and clock gating are also defined during this step.

**Routing: **Routing involves connecting the components placed on the chip in a way that satisfies the specified timing and electrical constraints. Global routing connects major blocks, while detailed routing creates the final detailed interconnections.

**Power Distribution Network:** The power distribution network (PDN) is designed to provide a stable and efficient power supply to all components of the ASIC. This includes power grid design and the placement of decoupling capacitors.

**Signal Integrity and Timing Analysis: **Extensive analysis is performed to ensure that the chip meets the required timing constraints and that signal integrity is maintained throughout the design.

**Design for Manufacturability (DFM):** DFM considerations address issues related to manufacturing, yield, and reliability. Techniques are employed to mitigate manufacturing variations and improve the chances of successful fabrication.

**Physical Verification:** Various physical verification steps, including design rule checking (DRC) and layout vs. schematic (LVS) checks, are performed to ensure that the layout adheres to the foundry's process rules and is functionally correct.

**Extraction and Simulation:** Parasitic elements (resistance and capacitance) are extracted from the layout, and simulations are run to refine the timing and power models.

**Mask Generation:** The final layout data is used to create photomasks, which are used in the semiconductor fabrication process.

**Tapeout:** The tapeout is the process of submitting the final design files to the semiconductor foundry for fabrication. It's a critical step that marks the transition from design to manufacturing.


![image](https://github.com/eyemann/pes_wm/assets/142375203/61691e37-72db-4c54-baa0-5c52281f3fce)

![image](https://github.com/eyemann/pes_wm/assets/142375203/83648437-14fa-4774-8b4b-e16200ead70d)

<img width="417" alt="image" src="https://github.com/eyemann/pes_wm/assets/142375203/b77bec9f-5d18-4e18-acd7-8568a1c54081">


</details>











