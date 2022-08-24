####using statements####

#####structs#######

mutable struct tile 
    value::Int
    color::Int #(0,1,2,3)-->(R,G,B,Y)
    sortValue::Int

    tile(tileVal::Int, tileColor::Int) = new(tileVal, tileColor, tileVal * 10 + tileColor)
end

mutable struct tileGroup
    isMatching::Bool
    tiles::Array{tile}
end


#####functions######
function tileSort!(tiles::Array{tile})
    sort!(tiles, by = v -> v.sortValue)
end

function tilePrint(tiles::Array{tile})
    for tile in tiles
        print(tile.value)
        if(tile.color == 0)
            print(" Red")
        elseif(tile.color == 1)
            print(" Green")
        elseif(tile.color == 2)
            print(" Blue")
        elseif(tile.color == 3)
            print(" Yellow")
        else
            print(" unknown")
        end
        println()
    end
    
end

#code execution--for testing and then eventually running
begin

    #testing sorting and printing
    # testingList = [tile(10,1), tile(3,3), tile(5,0), tile(13,2)]
    # tilePrint(testingList)
    # tileSort!(testingList)
    # println()
    # tilePrint(testingList)
end