# search.py
# ---------------
# Licensing Information:  You are free to use or extend this projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to the University of Illinois at Urbana-Champaign
#
# Created by Michael Abir (abir2@illinois.edu) on 08/28/2018

"""
This is the main entry point for MP1. You should only modify code
within this file -- the unrevised staff files will be used for all other
files and classes when code is run, so be careful to not modify anything else.
"""
# Taking Graph and Kruskal's algo from https://www.geeksforgeeks.org/kruskals-minimum-spanning-tree-algorithm-greedy-algo-2/
# Python program for Kruskal's algorithm to find 
# Minimum Spanning Tree of a given connected,  
# undirected and weighted graph 
  
from collections import defaultdict 
import itertools
from itertools import chain, combinations
import bisect
  
#This code is contributed by Neelam Yadav 

# Search should return the path.
# The path should be a list of tuples in the form (row, col) that correspond
# to the positions of the path taken by your search algorithm.
# maze is a Maze object based on the maze from the file specified by input filename
# searchMethod is the search method specified by --method flag (bfs,dfs,astar,astar_multi,extra)

def search(maze, searchMethod):
    return {
        "bfs": bfs,
        "astar": astar,
        "astar_corner": astar_corner,
        "astar_multi": astar_multi,
        "extra": extra,
    }.get(searchMethod)(maze)
    
# return path from fin to start utilizing parent dictionary, from end node to start   
def return_path(oneesan, start, fin):
    retPath = [fin]
    curNode = fin
    while curNode != start:
        curNode = oneesan[curNode]
        retPath.insert(0, curNode)
    return retPath

# similar to above, returns length of current path
def length_path(oneesan, start, pos):
    path_len = 0
    currNode = pos
    while currNode != start:
        currNode = oneesan[currNode]
        path_len += 1
    return path_len

def bfs(maze):
    """
    Runs BFS for part 1 of the assignment.

    @param maze: The maze to execute the search on.

    @return path: a list of tuples containing the coordinates of each state in the computed path
    """
    # TODO: Write your code here
    explored = [[0 for i in range(maze.cols)] for j in range(maze.rows)] 
    # will treat entire map as explorable, including walls
    bfsQ = [] # queue of tuples
    oneesan = {} # because we have visited, can hold parent node data as **dictionary**

    startPos = maze.getStart()
    bfsQ.append(startPos)
    explored[startPos[0]][startPos[1]] = 1 # row then col 
    oneesan[startPos] = startPos # start position has no parent and is end of returned path
    
    while bfsQ:
        #expand a node
        currNode = bfsQ.pop(0) # stupid ass shit pop defaults to popping LAST element, wtf
        neighbors = maze.getNeighbors(currNode[0], currNode[1])
        if(maze.isObjective(currNode[0], currNode[1])==True):
            return return_path(oneesan, startPos, currNode)
        #add neighbors to queue
        for node in neighbors:
            # only want to append non visited neighbors, and mark them visited, and set parent
            if(explored[node[0]][node[1]]==0):
                explored[node[0]][node[1]] = 1
                bfsQ.append(node)        
                oneesan[node] = currNode # set parent node as well, only with unvisited nodes
    
    return []

def astar(maze):
    """
    Runs A star for part 1 of the assignment.

    @param maze: The maze to execute the search on.

    @return path: a list of tuples containing the coordinates of each state in the computed path
    """
    # TODO: Write your code here
    explored = [[0 for i in range(maze.cols)] for j in range(maze.rows)] 
    
    aQ = [] # queue of 3 tuples, x y dist
    oneesan = {} # dictionary is same

    startPos = maze.getStart()
    endPos = (maze.getObjectives())[0] # rets a list, get first obj, should be tuple of row,col

    # Manhattan dist is this equation below
    mDist = abs(endPos[0] - startPos[0]) + abs(endPos[1] - startPos[1])
    #bisect.insort(aQ, (mDist, startPos[0], startPos[1]))
    aQ.append((mDist, startPos[0], startPos[1]))
    explored[startPos[0]][startPos[1]] = 1 
    oneesan[startPos] = startPos 
    while aQ:
        #expand a node
        currNode = aQ.pop(0) # doesnt always find shortest if we pop(0)
        # currNode is tuple of dist, row, col
        neighbors = maze.getNeighbors(currNode[1], currNode[2])
        if(maze.isObjective(currNode[1], currNode[2])==True):
            return return_path(oneesan, startPos, (currNode[1], currNode[2]))
        #stupidly add neighbors to queue
        
        for node in neighbors:
            # only want to append non visited neighbors, and mark them visited, and set parent
            if(explored[node[0]][node[1]]==0):
                explored[node[0]][node[1]] = 1
                # before adding to this queue, must calcuate manh dist and keep array sorted
                mDist = abs(endPos[0] - node[0]) + abs(endPos[1] - node[1]) + length_path(oneesan, startPos, (currNode[1], currNode[2]))
                bisect.insort(aQ, (mDist, node[0], node[1]))  
                oneesan[node] = (currNode[1],currNode[2])
                #print(aQ)
    
    return []

def astar_dest(maze, startPos, corner, completed):
    """
    Runs A star for part 1 of the assignment.

    @param maze: The maze to execute the search on.

    @return path: a list of tuples containing the coordinates of each state in the computed path
    """
    # TODO: Write your code here
    explored = [[0 for i in range(maze.cols)] for j in range(maze.rows)] 
    
    aQ = [] # queue of 3 tuples, x y dist
    oneesan = {} # dictionary is same

    endPos = corner # rets a list, get first obj, should be tuple of row,col

    # Manhattan dist is this equation below
    mDist = abs(endPos[0] - startPos[0]) + abs(endPos[1] - startPos[1])
    #bisect.insort(aQ, (mDist, startPos[0], startPos[1]))
    aQ.append((mDist, startPos[0], startPos[1]))
    explored[startPos[0]][startPos[1]] = 1 
    oneesan[startPos] = startPos 
    while aQ:
        #expand a node
        currNode = aQ.pop(0) # doesnt always find shortest if we pop(0)
        # currNode is tuple of dist, row, col
        neighbors = maze.getNeighbors(currNode[1], currNode[2])
        if(currNode[1] == endPos[0] and currNode[2] == endPos[1]):
            completed.append( (currNode[1], currNode[2]))
            return return_path(oneesan, startPos, (currNode[1], currNode[2]))
        #stupidly add neighbors to queue
        
        for node in neighbors:
            # only want to append non visited neighbors, and mark them visited, and set parent
            if(explored[node[0]][node[1]]==0):
                explored[node[0]][node[1]] = 1
                # before adding to this queue, must calcuate manh dist and keep array sorted
                mDist = abs(endPos[0] - node[0]) + abs(endPos[1] - node[1])  + length_path(oneesan, startPos, (currNode[1], currNode[2]))
                bisect.insort(aQ, (mDist, node[0], node[1]))  
                oneesan[node] = (currNode[1],currNode[2])
                #print(aQ)
    
    return []

def closest_corner(maze, position, completed): #returns path to closes corner
    minimum = 100000
    #corners are treated as objectives, so go through obj list
    corners = maze.getObjectives()
    closest_corner = []
    dummy = [] #empty array to please input for astar_dest
    temp_path = []
    for objective in corners:
        temp_path = astar_dest(maze, position, objective, dummy)
        if len(temp_path) < minimum and objective not in completed:
            minimum = len(temp_path)
            closest_corner = temp_path
    completed.append(closest_corner[-1])
    return closest_corner
    

def astar_corner(maze):
    """
    Runs A star for part 2 of the assignment in the case where there are four corner objectives.
        
    @param maze: The maze to execute the search on.
        
    @return path: a list of tuples containing the coordinates of each state in the computed path
        """
    # TODO: Write your code here
    corners = maze.getObjectives()
    completed = [] # need global dictionary to keep track of explored corners across runs
    dummy = []
    final_path = []
    startPos = maze.getStart()
    return astar_multi(maze)
    final_path = closest_corner(maze, startPos, completed)#astar_dest(maze, startPos, first, completed)
    #print(final_path)
    
    #from here, closest doesnt guarantee best path. Simply compute other paths and choose shortest.
    minimum = 100000
    closest = (0,0)
    for corner in corners:
        if corner not in completed:
            #pass in dummy array, since these paths dont actually complete anything
            path = astar_dest(maze, final_path[-1], corner, dummy)
            if len(path) < minimum:
                minimum = len(path)
                closest = corner
    path = astar_dest(maze, final_path[-1], closest, completed)
    path.pop(0)
    final_path.extend( path)
    #print(final_path)
    
    
    minimum = 100000
    closest = (0,0)
    for corner in corners:
        if corner not in completed:
            path = astar_dest(maze, final_path[-1], corner, dummy)
            if len(path) < minimum:
                minimum = len(path)
                closest = corner
    path = astar_dest(maze, final_path[-1], closest, completed)
    path.pop(0)
    final_path.extend( path)
    #print(final_path)
    #print(completed)
    minimum = 100000
    closest = (0,0)
    for corner in corners:
        if corner not in completed:
            path = astar_dest(maze, final_path[-1], corner, dummy)
            if len(path) < minimum:
                minimum = len(path)
                closest = corner
    path = astar_dest(maze, final_path[-1], closest, completed)
    path.pop(0)
    final_path.extend( path)
    # print(final_path)
    return final_path

#got powerset function from here https://stackoverflow.com/questions/18035595/powersets-in-python-using-itertools
def powerset(iterable):
    "powerset([1,2,3]) --> () (1,) (2,) (3,) (1,2) (1,3) (2,3) (1,2,3)"
    s = list(iterable)
    return chain.from_iterable(combinations(s, r) for r in range(len(s)+1))

def subset2bitmask(subset):
    bitMask = 0
    for node in subset:
        bitMask |= (1 << node)
    return bitMask

# https://stackoverflow.com/questions/20517570/get-the-the-number-of-zeros-and-ones-of-a-binary-number-in-python
# def binary(num, length=4):
#     return format(num, '#0{}b'.format(length + 2)).replace('0b', '')

# Using Held-Karp algorithm
# roughly based off of psuedocode from wikipedia https://en.wikipedia.org/wiki/Held%E2%80%93Karp_algorithm#Pseudocode[5]
# and got important ideas from https://github.com/CarlEkerot/held-karp/blob/master/held-karp.py
# and https://github.com/tem3/held-karp/blob/master/held_karp.py
def astar_multi(maze):
    """
    Runs A star for part 3 of the assignment in the case where there are
    multiple objectives.

    @param maze: The maze to execute the search on.

    @return path: a list of tuples containing the coordinates of each state in the computed path
    """
    # TODO: Write your code here
    # build distance matrix 
    distances = {}
    pathfinder = {} # holds paths from dot to dot
    final_path = [] # holds optimal path
    tuple2node = {} # dict to convert position tuple to vertex
    startPos = maze.getStart()
    tuple2node[startPos] = 1 # assume tsp starts at some node 1
    nodeCount = 1
    dummy = []
    objectives = maze.getObjectives()
    if(len(objectives) >= 20):
        return []
    # dict to hold transition costs, start with init transitions first
    # KEYS - tuple (node, (sorted list of nodes)) ... use bisect.insort to keep list sorted
    # VALUES - tuple (cost, parent)
    Costs = {} 

    # converts tuple positions into vertices. Also makes edges from start to each node
    objectives.insert(0, startPos)
    objectives.append((-1,-1)) # adding fake node to convert cycle to path problem
    for tup in objectives:
        dummy = []
        tuple2node[tup] = nodeCount
        nodeCount += 1


    # fill distances, but use vertex naming rather than position tuple
    for dot in objectives:
        # get start to dot distances
        for otherdot in objectives: # fill distaces matrix, does not include start
            a = tuple2node[dot]
            b = tuple2node[otherdot]
            dummy = []
            if(dot == (-1,-1) and otherdot != dot):
                distances[(a, b)] = 10000
                distances[(b, a)] = 0
                pathfinder[(a,b)] = []
                pathfinder[(b,a)] = [] #wont use this so its ok
            elif(otherdot == (-1,-1) and dot != otherdot):
                distances[(a, b)] = 0
                distances[(b, a)] = 100000
                pathfinder[(a,b)] = []
                pathfinder[(b,a)] = []
            elif (a,b) not in distances and a != b and (b,a) not in distances:
                tempPath = astar_dest(maze, dot, otherdot, dummy)
                tempPath2 = tempPath[::-1]
                tempPath.pop(0)
                tempPath2.pop(0)

                distances[(a, b)] = len(tempPath)
                distances[(b, a)] = len(tempPath)
                # print("got dist ", distances[(a, b)], ' for ',a, b)          
                pathfinder[(a,b)] = tempPath
                pathfinder[(b,a)] = tempPath2 # reverse the list, for reverse path ofc
    dummy = []

    for i in range(1, nodeCount):
        bitMask = 1 << i
        if(i != 1):
            if(i == nodeCount):
                Costs[(i, bitMask)] = 100000
            else:    
                Costs[(i, bitMask)] = (distances[(1,i)], 1)#set parent to 0, fills with initial distances
        else:
            Costs[(i, bitMask)] = (0, 1)
        # print(Costs[(i, bitMask)])

    # print(Costs)
    # S = list(powerset(range(2, nodeCount))) # get all possible subsets first
    
    for S_size in range(2, nodeCount-1):
        S = itertools.combinations(range(2, nodeCount), S_size)
        for subset in S:
            if(len(subset) == S_size): # go through all subsets of increasing size, starting at 2
                # print('at subset ', subset)
                bitMask = subset2bitmask(subset)
                
                # all costs to achieve this subset, go over every node
                # print("{0:b}".format(bitMask), subset)
                # bits = binary(bitMask, nodeCount)
                # zeros = bits.count('0')
                for x in subset:
                    # get set that doesnt have node x, and its a bitmask 
                    if(x == nodeCount):
                        break
                    subsubsetMask = bitMask & ~(1 << x)
                    minimum = 100000
                    minNode = 0
                    # hueristic for min cost from wikipedia:  C(S, k) := min_m≠k,m∈S [C(S\{k}, m) + dm,k]
                    for y in subset: #used for going over every other node but x
                        if(minimum <= 1):
                            break
                        if(y != x):
                            tempCost = Costs[ (y, subsubsetMask)][0] + distances[(x, y)] 
                            if(tempCost <= minimum):
                                minimum = tempCost
                                minNode = y
                        
                            # elif(tempCost == minimum and distances[(x,y)] < minStart):
                                # minStart = distances[(x,y)]
                                # minNode = y

                    Costs[ (x, bitMask)] = (minimum, minNode) # TODO Consider decoupling parent from cost                        
                
    # get optimal path!
    minimum = 100000
    # minStart = 10000
    minNode = 0
    fullBitMask = subset2bitmask(range(2, nodeCount))
    # Now find best first step
    for k in range(2, nodeCount):
        # print('costs for ', k, '  is ', Costs[ (k, fullBitMask)][0], ' init is ', distances[(1,k)], ' total is ', Costs[ (k, fullBitMask)][0]+distances[(1,k)])
        tempCost = Costs[ (k, fullBitMask)][0] + distances[(1,k)] # need cost and initial distance
        if (tempCost < minimum):
            minimum = tempCost
            # minStart = distances[(1,k)]
            minNode = k
        # elif(tempCost == minimum and minStart > distances[(1,k)]):
        #     minStart = distances[(1,k)]
        #     minNode = k
    # print('best first step is ', minNode)
    # print('optimal cost is ', minimum)                
    tempParent = minNode
    final_path.append(startPos)
    final_path.extend(pathfinder[1, tempParent])
    
    minimum = 100000
    # idea: create explored dict, and punish backtracking over explored nodes alot, punish exploring new empty nodes a little
    subBitMask = fullBitMask
    while tempParent != 1:       
        oldtempParent = tempParent # need to store this before overwriting
        tempParent = Costs[(tempParent, subBitMask)][1]
        if(tempParent != 1):
            tempPath = pathfinder[(oldtempParent, tempParent)] #edge case
            final_path.extend(tempPath)

        subBitMask = subBitMask & ~(1 << oldtempParent)

    # print(final_path)
    return final_path


def extra(maze):
    """
    Runs extra credit suggestion.

    @param maze: The maze to execute the search on.

    @return path: a list of tuples containing the coordinates of each state in the computed path
    """
    # TODO: Write your code here
    return []# astar_multi(maze)
