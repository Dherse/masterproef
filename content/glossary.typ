#import "../elems/acronyms.typ": gloss_over, gloss
#import "../elems/template.typ": section

#gloss_over("prg", "PRG", "Photonics Research Group")
#gloss_over("fpga", "FPGA", "Field Programmable Gate Array")
#gloss_over("spice", "SPICE", "Simulation Program with Integrated Circuit Emphasis")
#gloss_over("phos", "PHÔS", "Photonic Hardware Description Language")
#gloss_over("pic", "PIC", "Photonic Integrated Circuit")
#gloss_over("rf", "RF", "Radio Frequency")
#gloss_over("verilog-ams", "Verilog-AMS", "Verilog for Analog and Mixed Signal")
#gloss_over("verilog-a", "Verilog-A")[#locate(loc => [Verilog for Analog, a continuous-time subset of #gloss("verilog-ams", short: true, format: if section.at(loc) == "preface" { "I" } else { "1" } )])]
#gloss_over("fir", "FIR", "Finite Impulse Response")
#gloss_over("iir", "IIR", "Infinite Impulse Response")
#gloss_over("dsp", "DSP", "Digital Signal Processor")
#gloss_over("fppga", "FPPGA", "Field Programmable Photonic Gate Array")