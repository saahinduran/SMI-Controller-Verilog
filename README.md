This repository consists of an SMI controller and RMII interface controller.
TOP module is not a qualified code, instead it is written for demonstration purposes.

This project is implemented on Nexys A7-100T FPGA board. A proper communication is established with the phy that presents on the board.


All the necessary files are provided.

A broadcast message is captured via ILA (internal logic analyzer)
->https://imgur.com/a/Rt1Neoq

See example usage:
->https://imgur.com/a/8chdezg
->16 bits register values are display as LED array.
->Switch 0 resets the whole logic.
->Switch 15..11 selects the register number to display.
