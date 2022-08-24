####using statements####

#####structs#######

struct tile 
    value::Int
    color::Int #(0,1,2,3)-->(R,G,B,Y)
    sortValue::Int

    tile(tileVal::Int, tileColor::Int) = new(tileVal, tileColor, tileVal * 10 + tileColor)
end

struct tileGroup
    isMatching::Bool
    tiles::Array{tile}

    tileGroup(isMatching::Bool, tiles::Array{tile}) = new(isMatching, tileSort(tiles))
end


#####functions######
function Base.copy(group::tileGroup)
    return tileGroup(group.isMatching, group.tiles)
end

function Base.copy(t::tile)
    return tile(t.value, t.color)
end

function tileSort!(tiles::Array{tile})
    sort!(tiles, by = v -> v.sortValue)
end

function tileSort(tiles::Array{tile})
    copytile = copy(tiles)
    tileSort!(copytile)
    return copytile
end

function tilePrint(tiles::Array{tile})
    for tile in tiles
        print(tile.value)
        if tile.color == 0
            print(" Red")
        elseif tile.color == 1
            print(" Green")
        elseif tile.color == 2
            print(" Blue")
        elseif tile.color == 3
            print(" Yellow")
        else
            print(" unknown")
        end
        println()
    end
    
end

function tileGroupsPrint(tileGroups::Array{tileGroup})


    println("___________")
    println()
    for group in tileGroups

        print("Group Type: ")
        if group.isMatching
            println("Matching")
        else
            println("Run")
        end
        
        tilePrint(group.tiles)

        println("___________")
        println()
    end

end

function compareGroups(group1::tileGroup, group2::tileGroup)
    #assumes both group1 and group2 are storted
    #check the obvious
    if group1.isMatching != group2.isMatching || length(group1.tiles) != length(group2.tiles)
        return false
    else
        for i = 1:length(group1.tiles)
            if(group1.tiles[i].sortValue != group2.tiles[i].sortValue)
                return false
            end
        end
        return true
    end




    
end

function add!(toAdd::tileGroup, groupList::Array{tileGroup})
    #add toAdd to groupList
    push!(groupList, copy(toAdd))
end

function remove!(removeGroup::tileGroup, tileList::Array{tile})

    for tile in removeGroup.tiles
        index = getIndexOf(tile, tileList)
        if index > 0
            deleteat!(tileList, index)
        else
            return false
        end
    end
    return true
end

function getIndexOf(find::tile, list::Array{tile})
    
    for i = 1:length(list)
        if find.sortValue == list[i].sortValue
            return i
        end
    end
    return -1
end

#code execution--for testing and then eventually running
begin

    testingList = [tile(10,1), tile(3,3), tile(5,0), tile(13,2),tile(2,3), tile(2, 2), tile(2, 1), tile(2,0)]
    testGroup = tileGroup(true, testingList[5:end])

    tilePrint(testingList)
    println()
    remove!(testGroup, testingList)
    tilePrint(testingList)
    tileGroupsPrint([testGroup])

    #testing sorting and printing
    # testingList = [tile(10,1), tile(3,3), tile(5,0), tile(13,2)]
    # tilePrint(testingList)
    # tileSort!(testingList)
    # println()
    # tilePrint(testingList)

    # plosgroup = [tile(2,3), tile(2, 1), tile(2, 2)]
    # testGroup = tileGroup(true, plosgroup)
    # testGroup2 = tileGroup(true, [tile(2,3), tile(2, 2), tile(2, 1), tile(2,0)])

    # groupArray = Vector{tileGroup}()
    # add!(testGroup, groupArray)
    # add!(testGroup2, groupArray)

    # tileGroupsPrint(groupArray)

    #testing tile groups and compare groups
    # plosgroup = [tile(2,3), tile(2, 1), tile(2, 2)]
    # tilePrint(plosgroup)
    # println("--------")
    # tilePrint(testGroup.tiles)
    # println("--------")
    # println(compareGroups(testGroup,testGroup2))

end