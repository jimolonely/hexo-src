---
title: python实现FP_Growth算法
tags:
  - python
  - AI
p: ai/001-fp_growth
date: 2018-01-18 17:10:20
---
本文将手动实现FP_Growth算法并挖掘关联规则.

# 定义FP树
```python
class TreeNode:
    '''定义FP树'''
    def __init__(self,nameValue,numOccur,parentNode):
        self.name = nameValue
        self.count = numOccur
        self.nodeLink = None
        self.parent = parentNode
        self.children = {}
    
    def inc(self,numOccur):
        self.count += numOccur
    
    def disp(self,ind=1):
        print('  '*ind,self.name,' ',self.count)
        for child in self.children.values():
            child.disp(ind+1)
```
测试:
```python
# 测试
rootNode = TreeNode('root',9,None)
rootNode.children['eye'] = TreeNode('eye',13,None)
rootNode.disp()
'''
root   9
     eye   13
'''
```
# 构建FP树
```python
# 构建FP树
def createTree(dataSet,minSup=1):
    headerTable = {}
    for trans in dataSet:
        for item in trans:
            headerTable[item] = headerTable.get(item,0) + dataSet[trans]
    # 去除不满足最小支持度的项
    for k in list(headerTable.keys()):
        if headerTable[k] < minSup:
            del(headerTable[k])
    freqItemSet = set(headerTable.keys())
    if len(freqItemSet) == 0: return None,None
    for k in headerTable:
        headerTable[k] = [headerTable[k],None]
    retTree = TreeNode('Null Set',1,None)
    for tranSet,count in dataSet.items():
        localD = {}
        for item in tranSet:
            if item in freqItemSet:
                localD[item] = headerTable[item][0]
        if len(localD) > 0:
            # 按频率降序排列
            orderedItems = [v[0] for v in sorted(localD.items(),key=lambda p: p[1],reverse=True)]
            updateTree(orderedItems,retTree,headerTable,count)
    return retTree,headerTable

def updateTree(items,inTree,headerTable,count):
    if items[0] in inTree.children:
        inTree.children[items[0]].inc(count)
    else:
        inTree.children[items[0]] = TreeNode(items[0],count,inTree)
        if headerTable[items[0]][1]==None:
            headerTable[items[0]][1] = inTree.children[items[0]]
        else:
            updateHeader(headerTable[items[0]][1],inTree.children[items[0]])
    if len(items)>1:
        updateTree(items[1::],inTree.children[items[0]],headerTable,count)

def updateHeader(nodeToTest,targetNode):
    while nodeToTest.nodeLink != None:
        nodeToTest = nodeToTest.nodeLink
    nodeToTest.nodeLink = targetNode
```
数据集:
```python
def loadDataSet():
    ds = [
        ['r','z','h','j','p'],
        ['z','y','x','w','v','u','t','s'],
        ['z'],
        ['r','x','n','o','s'],
        ['y','r','x','z','q','t','p'],
        ['y','z','x','e','q','s','t','m']
    ]
    return ds

def createInitSet(dataSet):
    retDict = {}
    for trans in dataSet:
        retDict[frozenset(trans)] = 1
    return retDict
```
测试:
```python
# 测试
ds = loadDataSet()
dataSet = createInitSet(ds)
dataSet
'''
{frozenset({'z'}): 1,
 frozenset({'h', 'j', 'p', 'r', 'z'}): 1,
 frozenset({'s', 't', 'u', 'v', 'w', 'x', 'y', 'z'}): 1,
 frozenset({'n', 'o', 'r', 's', 'x'}): 1,
 frozenset({'p', 'q', 'r', 't', 'x', 'y', 'z'}): 1,
 frozenset({'e', 'm', 'q', 's', 't', 'x', 'y', 'z'}): 1}
'''

myFPTree,myHeaderTab = createTree(dataSet,3)
myFPTree.disp()
'''
   Null Set   1
     z   5
       r   1
       x   3
         t   2
           s   2
             y   2
         r   1
           t   1
             y   1
     x   1
       r   1
         s   1
'''
```
# 寻找条件模式基
```python
def ascendTree(leafNode,prefixPath):
    if leafNode.parent != None:
        prefixPath.append(leafNode.name)
        ascendTree(leafNode.parent,prefixPath)

def findPrefixPath(basePat,treeNode):
    condPats = {}
    while treeNode != None:
        prefixPath = []
        ascendTree(treeNode,prefixPath)
        if len(prefixPath) > 1:
            condPats[frozenset(prefixPath[1:])] = treeNode.count
        treeNode = treeNode.nodeLink
    return condPats
```
测试:
```python
condPats = findPrefixPath('r',myHeaderTab['r'][1])
condPats
'''
{frozenset({'z'}): 1, frozenset({'x'}): 1, frozenset({'x', 'z'}): 1}
'''
```
# 创建条件FP树
```python
def mineTree(inTree,headerTable,minSup,preFix,freqItemSet):
    bigL = [v[0] for v in sorted(headerTable.items(),key=lambda p:p[1][0])]
    for basePat in bigL:
        newFreqSet = preFix.copy()
        newFreqSet.add(basePat)
        support = headerTable[basePat][0]
        freqItemSet[frozenset(newFreqSet)] = support
        condPattBases = findPrefixPath(basePat,headerTable[basePat][1])
        myCondTree , myHead = createTree(condPattBases,minSup)
        
        if myHead != None:
            # debug
            print('条件树:',newFreqSet)
            myCondTree.disp(1)
            mineTree(myCondTree,myHead,minSup,newFreqSet,freqItemSet)
```
测试:
```python
freqItems = {}
mineTree(myFPTree,myHeaderTab,3,set([]),freqItems)
'''
条件树: {'t'}
   Null Set   1
     z   3
       x   3
条件树: {'t', 'x'}
   Null Set   1
     z   3
条件树: {'s'}
   Null Set   1
     x   3
条件树: {'y'}
   Null Set   1
     z   3
       t   3
         x   3
条件树: {'y', 't'}
   Null Set   1
     z   3
条件树: {'y', 'x'}
   Null Set   1
     z   3
       t   3
条件树: {'y', 't', 'x'}
   Null Set   1
     z   3
条件树: {'x'}
   Null Set   1
     z   3
'''

freqItems
'''
{frozenset({'r'}): 3,
 frozenset({'t'}): 3,
 frozenset({'z'}): 5,
 frozenset({'t', 'z'}): 3,
 frozenset({'t', 'x'}): 3,
 frozenset({'t', 'x', 'z'}): 3,
 frozenset({'s'}): 3,
 frozenset({'s', 'x'}): 3,
 frozenset({'y'}): 3,
 frozenset({'y', 'z'}): 3,
 frozenset({'t', 'y'}): 3,
 frozenset({'t', 'y', 'z'}): 3,
 frozenset({'x'}): 4,
 frozenset({'x', 'y'}): 3,
 frozenset({'x', 'y', 'z'}): 3,
 frozenset({'t', 'x', 'y'}): 3,
 frozenset({'x', 'z'}): 3,
 frozenset({'t', 'x', 'y', 'z'}): 3}
'''
```
# 挖掘关联规则
```python
def ruleGenerator(freqItems,minConf,rules):
    for freqItemSet in freqItems:
        if len(freqItemSet)>1:
            getRules(freqItemSet,freqItemSet,rules,freqItems,minConf)

def removeStr(set, str):
    tempSet = []
    for elem in set:
        if(elem != str):
            tempSet.append(elem)
    tempFrozenSet = frozenset(tempSet)
    return tempFrozenSet

def getRules(freqItemSet,currSet,rules,freqItems,minConf):
    for freqElem in currSet:
        subSet = removeStr(currSet,freqElem)
        confidence = freqItems[freqItemSet] / freqItems[subSet]
        if confidence >= minConf:
            flag = False
            for rule in rules:
                if rule[0]==subSet and rule[1]==freqItemSet-subSet:
                    flag = True
            if flag == False:
                rules.append((subSet,freqItemSet-subSet,confidence))
            if len(subSet)>=2:
                getRules(freqItemSet,subSet,rules,freqItems,minConf)
```
测试:
```python
rules = []
ruleGenerator(freqItems,0.6,rules)
rules
'''
[(frozenset({'t'}), frozenset({'z'}), 1.0),
 (frozenset({'z'}), frozenset({'t'}), 0.6),
 (frozenset({'x'}), frozenset({'t'}), 0.75),
 (frozenset({'t'}), frozenset({'x'}), 1.0),
 (frozenset({'t', 'x'}), frozenset({'z'}), 1.0),
 (frozenset({'x'}), frozenset({'t', 'z'}), 0.75),
 (frozenset({'t'}), frozenset({'x', 'z'}), 1.0),
 (frozenset({'x', 'z'}), frozenset({'t'}), 1.0),
 (frozenset({'z'}), frozenset({'t', 'x'}), 0.6),
 (frozenset({'t', 'z'}), frozenset({'x'}), 1.0),
 (frozenset({'x'}), frozenset({'s'}), 0.75),
 (frozenset({'s'}), frozenset({'x'}), 1.0),
 (frozenset({'z'}), frozenset({'y'}), 0.6),
 (frozenset({'y'}), frozenset({'z'}), 1.0),
 (frozenset({'t'}), frozenset({'y'}), 1.0),
 (frozenset({'y'}), frozenset({'t'}), 1.0),
 (frozenset({'t', 'z'}), frozenset({'y'}), 1.0),
 (frozenset({'t'}), frozenset({'y', 'z'}), 1.0),
 (frozenset({'z'}), frozenset({'t', 'y'}), 0.6),
 ...
'''
```
# 备注
以上来源于<<机器学习实战>>.

觉得IBM的博客也不错:[https://www.ibm.com/developerworks/cn/analytics/library/machine-learning-hands-on2-fp-growth/index.html](https://www.ibm.com/developerworks/cn/analytics/library/machine-learning-hands-on2-fp-growth/index.html)

# 最后是封装好的类代码
```python
class _TreeNode:
    '''定义FP树'''

    def __init__(self, nameValue, numOccur, parentNode):
        self.name = nameValue
        self.count = numOccur
        self.nodeLink = None
        self.parent = parentNode
        self.children = {}

    def inc(self, numOccur):
        self.count += numOccur

    def disp(self, ind=1):
        print('  ' * ind, self.name, ' ', self.count)
        for child in self.children.values():
            child.disp(ind + 1)


class JFPGrowth(object):
    def __init__(self, dataSet, minSupport=0.1, minConfidence=0.6):
        self.__dataSet = self.__createInitSet(dataSet)
        self.minSup = int(minSupport * len(self.__dataSet)) + 1
        self.minConf = minConfidence
        self.__freqItems = {}
        self.__rules = []

    def __createInitSet(self, dataSet):
        retDict = {}
        for trans in dataSet:
            retDict[frozenset(trans)] = 1
        return retDict

    def __createTree(self, dataSet):
        '''
        构建FP树
        '''
        headerTable = {}
        for trans in dataSet:
            for item in trans:
                headerTable[item] = headerTable.get(item, 0) + dataSet[trans]
        # 去除不满足最小支持度的项
        for k in list(headerTable.keys()):
            if headerTable[k] < self.minSup:
                del (headerTable[k])
        freqItemSet = set(headerTable.keys())
        if len(freqItemSet) == 0: return None, None
        for k in headerTable:
            headerTable[k] = [headerTable[k], None]
        retTree = _TreeNode('Null Set', 1, None)
        for tranSet, count in dataSet.items():
            localD = {}
            for item in tranSet:
                if item in freqItemSet:
                    localD[item] = headerTable[item][0]
            if len(localD) > 0:
                # 按频率降序排列
                orderedItems = [v[0] for v in sorted(localD.items(), key=lambda p: p[1], reverse=True)]
                self.__updateTree(orderedItems, retTree, headerTable, count)
        return retTree, headerTable

    def __updateTree(self, items, inTree, headerTable, count):
        if items[0] in inTree.children:
            inTree.children[items[0]].inc(count)
        else:
            inTree.children[items[0]] = _TreeNode(items[0], count, inTree)
            if headerTable[items[0]][1] == None:
                headerTable[items[0]][1] = inTree.children[items[0]]
            else:
                self.__updateHeader(headerTable[items[0]][1], inTree.children[items[0]])
        if len(items) > 1:
            self.__updateTree(items[1::], inTree.children[items[0]], headerTable, count)

    def __updateHeader(self, nodeToTest, targetNode):
        while nodeToTest.nodeLink != None:
            nodeToTest = nodeToTest.nodeLink
        nodeToTest.nodeLink = targetNode

    def __ascendTree(self, leafNode, prefixPath):
        '''
        寻找条件模式基
        '''
        if leafNode.parent != None:
            prefixPath.append(leafNode.name)
            self.__ascendTree(leafNode.parent, prefixPath)

    def __findPrefixPath(self, basePat, treeNode):
        condPats = {}
        while treeNode != None:
            prefixPath = []
            self.__ascendTree(treeNode, prefixPath)
            if len(prefixPath) > 1:
                condPats[frozenset(prefixPath[1:])] = treeNode.count
            treeNode = treeNode.nodeLink
        return condPats

    def __mineTree(self, inTree, headerTable, preFix):
        '''
        创建条件FP树
        '''
        bigL = [v[0] for v in sorted(headerTable.items(), key=lambda p: p[1][0])]
        for basePat in bigL:
            newFreqSet = preFix.copy()
            newFreqSet.add(basePat)
            support = headerTable[basePat][0]
            self.__freqItems[frozenset(newFreqSet)] = support
            condPattBases = self.__findPrefixPath(basePat, headerTable[basePat][1])
            myCondTree, myHead = self.__createTree(condPattBases)

            if myHead != None:
                # debug
                # print('条件树:', newFreqSet)
                # myCondTree.disp(1)
                self.__mineTree(myCondTree, myHead, newFreqSet)

    def __ruleGenerator(self):
        '''
        挖掘关联规则
        '''
        for freqItemSet in self.__freqItems:
            if len(freqItemSet) > 1:
                self.__getRules(freqItemSet, freqItemSet)

    def __removeStr(self, set, str):
        tempSet = []
        for elem in set:
            if (elem != str):
                tempSet.append(elem)
        tempFrozenSet = frozenset(tempSet)
        return tempFrozenSet

    def __getRules(self, freqItemSet, currSet):
        for freqElem in currSet:
            subSet = self.__removeStr(currSet, freqElem)
            confidence = self.__freqItems[freqItemSet] / self.__freqItems[subSet]
            if confidence >= self.minConf:
                flag = False
                for rule in self.__rules:
                    if rule[0] == subSet and rule[1] == freqItemSet - subSet:
                        flag = True
                if flag == False:
                    self.__rules.append((subSet, freqItemSet - subSet, confidence))
                if len(subSet) >= 2:
                    self.__getRules(freqItemSet, subSet)

    def getFreqItems(self):
        tree, header = self.__createTree(self.__dataSet)
        self.__mineTree(tree, header, set([]))
        return self.__freqItems

    def getFinalRules(self):
        # 如果没有生成频繁集先要生成
        if len(self.__freqItems) == 0:
            self.getFreqItems()
        self.__ruleGenerator()
        return self.__rules
```
使用:
```python
from myalgo.my_fp_growth import JFPGrowth


def loadDataSet():
    ds = [['bread', 'milk', 'vegetable', 'fruit', 'eggs'],
          ['noodle', 'beef', 'pork', 'water', 'socks', 'gloves', 'shoes', 'rice'],
          ['socks', 'gloves'],
          ['bread', 'milk', 'shoes', 'socks', 'eggs'],
          ['socks', 'shoes', 'sweater', 'cap', 'milk', 'vegetable', 'gloves'],
          ['eggs', 'bread', 'milk', 'fish', 'crab', 'shrimp', 'rice']]
    return ds

dataSet = loadDataSet()

fp = JFPGrowth(dataSet, minSupport=0.3)

freqSets = fp.getFreqItems()

print(len(freqSets))
print(freqSets)

rules = fp.getFinalRules()

print(rules)
```