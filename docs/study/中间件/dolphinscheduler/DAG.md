#### 什么是dag
dag是有向无环图的简称，是图的一种数据结构
具体来说，它由有限个顶点和有向边组成，每条有向边都从一个顶点指向另一个顶点；从任意一个顶点出发都不能通过这些有向边回到原来的顶点 （关键：判断有向图中是否存在有向环。进行拓扑排序，如果能完成排序，则无环，否则有环 ）
图的一些基本术语
```
顶点：图中的一个点

边：连接两个顶点的线段

相邻：一个边的两头顶点成为相邻

度数：由一个顶点出发，有几条边就称该顶点有几度
出度：由一个顶点出发的边的总数；
入度：指向一个顶点的边的总

路径：通过边来连接，按顺序的从一个顶点到另一个顶点中间经过的顶点集合

简单路径：没有重复顶点的路径

环：至少含有一条边，并且起点和终点都是同一个顶点的路径


```
#### 什么是拓扑排序
定义：就是一个有向无环图的所有定点的线性序列。
```
先找一个顶点，如果没有其他节点指向它；
则删除该节点及其指向的边，记录该节点；
重复上面两个步骤，直到所有节点都被删除掉；
如果某节点存在有边指向其自己，则该图不属于有向无环图。
```
举例
例如，下面这个图：

![1721980329458.png](https://qiniu.muluofeng.com/1721980329458.png)

显然是一个DAG图，1→4表示4的入度+1，4是1的邻接点,


如何写出拓扑排序代码？

1.首先将边与边的关系确定，建立好入度表和邻接表。

2.从入度为0的点开始删除，如上图显然是1的入度为0，先删除。


![1721980395649.png](https://qiniu.muluofeng.com/1721980395649.png)

3.于是，得到拓扑排序后的结果是 { 1, 2, 4, 3, 5 }。通常，一个有向无环图可以有一个或多个拓扑排序序列。因为同一入度级别的点可以有不同的排序方式。

4.拓扑排序可以判断图中有无环，如下图

![1721980406032.png](https://qiniu.muluofeng.com/1721980406032.png)



显然4，5，6入度都是1，不存在入度为0的点，无法进行删除操作。判断有无环的方法，对入度数组遍历，如果有的点入度不为0，则表明有环。

#### dag核心代码实现
dolphinscheduler DAG实现

```java


import org.apache.commons.collections4.CollectionUtils;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import lombok.extern.slf4j.Slf4j;

/**
 * analysis of DAG
 * Node: node
 * NodeInfo：node description information
 * EdgeInfo: edge description information
 */
@Slf4j
public class DAG<Node, NodeInfo, EdgeInfo> {

    /**
     * 读写锁 主要对下面3个map操作进行读写锁
     */
    private final ReadWriteLock lock = new ReentrantReadWriteLock();

    /**
     *  记录所有dag节点的map
     */
    private final Map<Node, NodeInfo> nodesMap;

    /**
     *  记录所有以node为起始节点的 对应的边 和目标节点的信息
     */
    private final Map<Node, Map<Node, EdgeInfo>> edgesMap;

    /**
     *  记录所有以node为结束节点的 对应的边 和起始节点的信息
     */
    private final Map<Node, Map<Node, EdgeInfo>> reverseEdgesMap;

    public DAG() {
        nodesMap = new HashMap<>();
        edgesMap = new HashMap<>();
        reverseEdgesMap = new HashMap<>();
    }

    /**
     * 添加节点 获取写锁把节点加入到nodemap
     */
    public void addNode(Node node, NodeInfo nodeInfo) {
        lock.writeLock().lock();

        try {
            nodesMap.put(node, nodeInfo);
        } finally {
            lock.writeLock().unlock();
        }

    }

    /**
     * 添加边
     */
    public boolean addEdge(Node fromNode, Node toNode) {
        return addEdge(fromNode, toNode, false);
    }

    /**
     * 添加边
     */
    private boolean addEdge(Node fromNode, Node toNode, boolean createNode) {
        return addEdge(fromNode, toNode, null, createNode);
    }

    /**
     * 添加边
     */
    public boolean addEdge(Node fromNode, Node toNode, EdgeInfo edge, boolean createNode) {
        lock.writeLock().lock();

        try {
            // Whether an edge can be successfully added(fromNode -> toNode)
            if (!isLegalAddEdge(fromNode, toNode, createNode)) {
                log.error("serious error: add edge({} -> {}) is invalid, cause cycle！", fromNode, toNode);
                return false;
            }

            addNodeIfAbsent(fromNode, null);
            addNodeIfAbsent(toNode, null);

            addEdge(fromNode, toNode, edge, edgesMap);
            addEdge(toNode, fromNode, edge, reverseEdgesMap);

            return true;
        } finally {
            lock.writeLock().unlock();
        }

    }

    /**
     * whether this node is contained
     *
     * @param node node
     * @return true if contains
     */
    public boolean containsNode(Node node) {
        lock.readLock().lock();

        try {
            return nodesMap.containsKey(node);
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * whether this edge is contained
     *
     * @param fromNode node of origin
     * @param toNode node of destination
     * @return true if contains
     */
    public boolean containsEdge(Node fromNode, Node toNode) {
        lock.readLock().lock();
        try {
            Map<Node, EdgeInfo> endEdges = edgesMap.get(fromNode);
            if (endEdges == null) {
                return false;
            }

            return endEdges.containsKey(toNode);
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * get node description
     *
     * @param node node
     * @return node description
     */
    public NodeInfo getNode(Node node) {
        lock.readLock().lock();

        try {
            return nodesMap.get(node);
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * Get the number of nodes
     *
     * @return the number of nodes
     */
    public int getNodesCount() {
        lock.readLock().lock();

        try {
            return nodesMap.size();
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * Get the number of edges
     *
     * @return the number of edges
     */
    public int getEdgesCount() {
        lock.readLock().lock();
        try {
            int count = 0;

            for (Map.Entry<Node, Map<Node, EdgeInfo>> entry : edgesMap.entrySet()) {
                count += entry.getValue().size();
            }

            return count;
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * get the start node of DAG
     *
     * @return the start node of DAG
     */
    public Collection<Node> getBeginNode() {
        lock.readLock().lock();

        try {
            return CollectionUtils.subtract(nodesMap.keySet(), reverseEdgesMap.keySet());
        } finally {
            lock.readLock().unlock();
        }

    }

    /**
     * get the end node of DAG
     *
     * @return the end node of DAG
     */
    public Collection<Node> getEndNode() {
        lock.readLock().lock();

        try {
            return CollectionUtils.subtract(nodesMap.keySet(), edgesMap.keySet());
        } finally {
            lock.readLock().unlock();
        }

    }

    /**
     * Gets all previous nodes of the node
     *
     * @param node node id to be calculated
     * @return all previous nodes of the node
     */
    public Set<Node> getPreviousNodes(Node node) {
        lock.readLock().lock();

        try {
            return getNeighborNodes(node, reverseEdgesMap);
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * Get all subsequent nodes of the node
     *
     * @param node node id to be calculated
     * @return all subsequent nodes of the node
     */
    public Set<Node> getSubsequentNodes(Node node) {
        lock.readLock().lock();

        try {
            return getNeighborNodes(node, edgesMap);
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * Gets the degree of entry of the node
     *
     * @param node node id
     * @return the degree of entry of the node
     */
    public int getIndegree(Node node) {
        lock.readLock().lock();

        try {
            return getPreviousNodes(node).size();
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * whether the graph has a ring
     *
     * @return true if has cycle, else return false.
     */
    public boolean hasCycle() {
        lock.readLock().lock();
        try {
            return !topologicalSortImpl().getKey();
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * Only DAG has a topological sort
     *
     * @return topologically sorted results, returns false if the DAG result is a ring result
     * @throws Exception errors
     */
    public List<Node> topologicalSort() throws Exception {
        lock.readLock().lock();

        try {
            Map.Entry<Boolean, List<Node>> entry = topologicalSortImpl();

            if (entry.getKey()) {
                return entry.getValue();
            }

            throw new Exception("serious error: graph has cycle ! ");
        } finally {
            lock.readLock().unlock();
        }
    }

    /**
     * if tho node does not exist,add this node
     *
     * @param node node
     * @param nodeInfo node information
     */
    private void addNodeIfAbsent(Node node, NodeInfo nodeInfo) {
        if (!containsNode(node)) {
            addNode(node, nodeInfo);
        }
    }

    /**
     * add edge
     *
     * @param fromNode node of origin
     * @param toNode node of destination
     * @param edge edge description
     * @param edges edge set
     */
    private void addEdge(Node fromNode, Node toNode, EdgeInfo edge, Map<Node, Map<Node, EdgeInfo>> edges) {
        edges.putIfAbsent(fromNode, new HashMap<>());
        Map<Node, EdgeInfo> toNodeEdges = edges.get(fromNode);
        toNodeEdges.put(toNode, edge);
    }

    /**
     *  fromNode是否可以加入到toNode(fromNode -> toNode)
     *  检测dag是否有环
     */
    private boolean isLegalAddEdge(Node fromNode, Node toNode, boolean createNode) {
        //起始节点和结束节点一样不能添加
        if (fromNode.equals(toNode)) {
            log.error("edge fromNode({}) can't equals toNode({})", fromNode, toNode);
            return false;
        }
       
        if (!createNode) {
             //不需要创建节点     需要校验 fromNode和 toNode 是否存在
            if (!containsNode(fromNode) || !containsNode(toNode)) {
                log.error("edge fromNode({}) or toNode({}) is not in vertices map", fromNode, toNode);
                return false;
            }
        }

        // Whether an edge can be successfully added(fromNode -> toNode),need to determine whether the DAG has cycle!
        int verticesCount = getNodesCount();

        Queue<Node> queue = new LinkedList<>();

        queue.add(toNode);

        // if DAG doesn't find fromNode, it's not has cycle!
        while (!queue.isEmpty() && (--verticesCount > 0)) {
            Node key = queue.poll();

            for (Node subsequentNode : getSubsequentNodes(key)) {
                if (subsequentNode.equals(fromNode)) {
                    return false;
                }

                queue.add(subsequentNode);
            }
        }

        return true;
    }

    /**
     * Get all neighbor nodes of the node
     *
     * @param node Node id to be calculated
     * @param edges neighbor edge information
     * @return all neighbor nodes of the node
     */
    private Set<Node> getNeighborNodes(Node node, final Map<Node, Map<Node, EdgeInfo>> edges) {
        final Map<Node, EdgeInfo> neighborEdges = edges.get(node);
        if (neighborEdges == null) {
            return Collections.emptySet();
        }
        return neighborEdges.keySet();
    }

    /**
     * 拓扑排序
     */
    private Map.Entry<Boolean, List<Node>> topologicalSortImpl() {
        // node queue with degree of entry 0
        Queue<Node> zeroIndegreeNodeQueue = new LinkedList<>();
        // save result
        List<Node> topoResultList = new ArrayList<>();
        // save the node whose degree is not 0
        Map<Node, Integer> notZeroIndegreeNodeMap = new HashMap<>();

        // Scan all the vertices and push vertexs with an entry degree of 0 to queue
        for (Map.Entry<Node, NodeInfo> vertices : nodesMap.entrySet()) {
            Node node = vertices.getKey();
            int inDegree = getIndegree(node);

            if (inDegree == 0) {
                zeroIndegreeNodeQueue.add(node);
                topoResultList.add(node);
            } else {
                notZeroIndegreeNodeMap.put(node, inDegree);
            }
        }

        /*
         * After scanning, there is no node with 0 degree of entry, indicating that there is a ring, and return directly
         */
        if (zeroIndegreeNodeQueue.isEmpty()) {
            return new AbstractMap.SimpleEntry<>(false, topoResultList);
        }

        // The topology algorithm is used to delete nodes with 0 degree of entry and its associated edges
        while (!zeroIndegreeNodeQueue.isEmpty()) {
            Node v = zeroIndegreeNodeQueue.poll();
            // Get the neighbor node
            Set<Node> subsequentNodes = getSubsequentNodes(v);

            for (Node subsequentNode : subsequentNodes) {

                Integer degree = notZeroIndegreeNodeMap.get(subsequentNode);

                if (--degree == 0) {
                    topoResultList.add(subsequentNode);
                    zeroIndegreeNodeQueue.add(subsequentNode);
                    notZeroIndegreeNodeMap.remove(subsequentNode);
                } else {
                    notZeroIndegreeNodeMap.put(subsequentNode, degree);
                }

            }
        }

        // if notZeroIndegreeNodeMap is empty,there is no ring!
        return new AbstractMap.SimpleEntry<>(notZeroIndegreeNodeMap.size() == 0, topoResultList);
    }

    /**
     * 获取所有的node
     */
    public Set<Node> getAllNodesList() {
        return nodesMap.keySet();
    }

    @Override
    public String toString() {
        return "DAG{"
                + "nodesMap="
                + nodesMap
                + ", edgesMap="
                + edgesMap
                + ", reverseEdgesMap="
                + reverseEdgesMap
                + '}';
    }
}

```

