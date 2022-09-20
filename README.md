# rummicube

This project takes an assortment of rummicube tiles and tries to sort them according to the rules of the game Rummicube (see here https://tesera.ru/images/items/784463/Rummikub_Rules.pdf). 

This algorithm recursivly searches through the set of tiles to either find a grouping that uses all the tiles, or tells the user that there is no grouping for all of the tiles. 

The algorithm works by making a guess at one group of tiles, removing it from the batch, and then repeating on the smaller subset. If the program gets to the end and there are still tiles remaining, it moves back a layer and tries a different random grouping. 

The time complexity of this algorithm is exponential, and tends to be too slow to be useable at around 30 tiles. 

The program also includes a way to get plots of runtime vs. tile count which clearly show the exponential behavior. 
