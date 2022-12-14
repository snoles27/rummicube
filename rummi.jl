####using statements####
using Plots

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

function Base.print(tiles::Array{tile})
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

function Base.print(tileGroups::Array{tileGroup})


    println("___________")
    println()
    for group in tileGroups

        print("Group Type: ")
        if group.isMatching
            println("Matching")
        else
            println("Run")
        end
        
        print(group.tiles)

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

function compareGroups(group1::tileGroup, groupList::Array{tileGroup})
    result = false
    for group in groupList
        if compareGroups(group, group1)
            result = true
        end
    end
    return result
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

function remove!(tile::tile, tileList::Array{tile})

    index = getIndexOf(tile, tileList)
    if index > 0
        deleteat!(tileList, index)
        return true
    else
        return false
    end

end

function containsAll(group::tileGroup, tileList::Array{tile})
    #returns true if all tiles in group are also in tileList
    for tile in group.tiles
        if getIndexOf(tile, tileList) == -1
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

function findGroup(tileList::Array{tile}, notAllowed::Array{tileGroup}, startIndex::Int)

    colorTotals = colorTally(tileList)

    for i = startIndex:length(tileList)
        color = tileList[i].color
        number = tileList[i].value
        for j = 1:2
            if j == 1 #Matching  
                possibilities = getCombinations(color, number)
                for trygroup in possibilities
                    if(containsAll(trygroup, tileList) && !compareGroups(trygroup, notAllowed))
                        return trygroup, i
                    end
                end
            else #run 
                if colorTotals[color + 1] >= 3
                    for k = 3:colorTotals[color + 1]
                        trygroup = getRun(tileList[i].value, color, k)
                        if(containsAll(trygroup, tileList) && !compareGroups(trygroup, notAllowed))
                            return trygroup, i
                        end
                    end
                end
            end
        end
    end
    return tileGroup(true, Vector{tile}()), -1
end

function equals(tile1::tile, tile2::tile)
    #returns true if tile1 is the same as tile2
    return (tile1.sortValue - tile2.sortValue) == 0
end

function getCombinations(startColor::Int, number::Int)

    allPossible3s = [0 1 2; 0 1 3; 0 2 3; 1 2 3]

    #remove possiblilties that dont have the starting color
    for i = 1:size(allPossible3s)[1]
        if !(startColor in allPossible3s[i,:])
            allPossible3s = allPossible3s[1:end .!= i, :]
            break
        end
    end

    #make group array
    groupList = Vector{tileGroup}()
    for i = 1:size(allPossible3s)[1]
        tempList = Vector{tile}()
        for j = 1:3
            push!(tempList, tile(number, allPossible3s[i,j]))
        end
        push!(groupList, tileGroup(true, tempList))
    end

    #add the 4 one to the group list
    push!(groupList, tileGroup(true, [tile(number, 0), tile(number, 1), tile(number, 2), tile(number, 3)]))

    return groupList

end

function getRun(startNumber::Int, color::Int, length::Int)

    tileArray = Vector{tile}()
    for i = 0:length-1
        push!(tileArray, tile(startNumber + i, color))
    end

    return tileGroup(false, tileArray)
end

function attempt!(activeSet::Array{tile}, groupList::Array{tileGroup})
    notAllowed = Vector{tileGroup}()
    layerSolved = false
    startSeach = 1
    while(!layerSolved)
        localSet = copy(activeSet)
        tempGroup, leftOffAt = findGroup(localSet, notAllowed, startSeach)
        startSeach = leftOffAt
        remove!(tempGroup, localSet)
        if length(tempGroup.tiles) == 0
            return 0
        elseif length(localSet) == 0
            add!(tempGroup, groupList)
            return 1
        else
            result = attempt!(localSet, groupList)
            if result == 0
                add!(tempGroup, notAllowed)
            else
                add!(tempGroup, groupList)
                layerSolved = true
            end
        end

    end
    return 1
end

function colorTally(tileList::Array{tile})

    numColor = zeros(Int, 4)
    for tile in tileList
        if tile.color == 0
            numColor[1] = numColor[1] + 1
        elseif tile.color == 1
            numColor[2] = numColor[2] + 1
        elseif tile.color == 2
            numColor[3] = numColor[3] + 1
        elseif tile.color == 3
            numColor[4] = numColor[4] + 1
        end
    end
    return numColor
end

function runAndPrint(tileList::Array{tile})
    tileSort!(tileList)
    print(tileList)
    println()
    print("n = ")
    println(length(tileList))
    println()

    groupList = Vector{tileGroup}()

    println("_______Performance Data_______")
    println()
    status =  @timev attempt!(tileList, groupList)
    println("______________________________")
    println()

    if (status == 1)
        println("SUCCESS")
        print(groupList)
    else
        println("fail")
    end

end

function getRandomTiles(numTiles::Int)

    tileList = Vector{tile}()
    for i = 1:numTiles
        push!(tileList, tile(rand(1:13), rand(1:4) - 1))
    end

    return tileList

end

function getTimePlot(startNum::Int, endNum::Int)
    
    numTrials = 5
    timeArray = Vector{Float64}()
    numArray = collect(startNum:endNum)
    for i in numArray
        time = 0
        for j = 1:numTrials
            tileList = getRandomTiles(i)
            time = time + @elapsed attempt!(tileList, Vector{tileGroup}())
        end
        time = time / numTrials
        push!(timeArray, time)
    end
    b = log.(timeArray)
    A = hcat(numArray, ones(length(numArray)))
    x = A \ b

    f(n) = x[1] * n + x[2]

    #scatter(numArray, timeArray, yaxis=:log)
    scatter(numArray, b, label = "Data")
    plot!(numArray, f.(numArray), label = "Linear Fit")
    xlabel!("Number of Tiles")
    ylabel!("log(time to complete)")

end

#code execution--for testing and then eventually running
begin


    #tileList = [tile(1,0), tile(2,1), tile(2, 0), tile(2,2), tile(2,3), tile(3,0), tile(4,0), tile(1,1), tile(1,2), tile(3,3), tile(4,3), tile(5,3), tile(6,3), tile(7,3), tile(6,1), tile(6,2), tile(6,0), tile(8,3), tile(9,3), tile(1,0), tile(1,1), tile(1,2), tile(1,3), tile(10,1), tile(10,2), tile(10,3), tile(11,3), tile(11,0), tile(11,1), tile(5,0), tile(3,1)]

    #tileList = getRandomTiles(31)
    #runAndPrint(tileList)

    getTimePlot(10, 28)



    # notAllowed = Vector{tileGroup}()
    # push!(notAllowed, findGroup(testingList, notAllowed, 1))
    # remove!(notAllowed[1], testingList)
    # print(notAllowed)
    # println("__________")
    # push!(notAllowed, findGroup(testingList, notAllowed, 1))
    # print(notAllowed)
    
    
    # print(getCombinations(1, 3))

    # group = getRun(4, 2, 5)
    # print([group])
    
    #a = a[1:end .!=2, :] example removing the second row

    # testingList = [tile(10,1), tile(3,3), tile(5,0), tile(13,2),tile(2,3), tile(2, 2), tile(2, 1), tile(2,0)]
    # testGroup = tileGroup(true, testingList[5:end])

    # print(testingList)
    # println()
    # remove!(testGroup, testingList)
    # print(testingList)
    # print([testGroup])



    #testing sorting and printing
    # testingList = [tile(10,1), tile(3,3), tile(5,0), tile(13,2)]
    # print(testingList)
    # tileSort!(testingList)
    # println()
    # print(testingList)

    # plosgroup = [tile(2,3), tile(2, 1), tile(2, 2)]
    # testGroup = tileGroup(true, plosgroup)
    # testGroup2 = tileGroup(true, [tile(2,3), tile(2, 2), tile(2, 1), tile(2,0)])

    # groupArray = Vector{tileGroup}()
    # add!(testGroup, groupArray)
    # add!(testGroup2, groupArray)

    # print(groupArray)

    #testing tile groups and compare groups
    # plosgroup = [tile(2,3), tile(2, 1), tile(2, 2)]
    # print(plosgroup)
    # println("--------")
    # print(testGroup.tiles)
    # println("--------")
    # println(compareGroups(testGroup,testGroup2))

end