extends Node
class_name PriorityQueue

var heap: Array = []

# Push a value with a priority into the heap
func push(value, priority):
    heap.append({"value": value, "priority": priority})
    _heapify_up(heap.size() - 1)

# Pop the value with the lowest priority (highest priority in a min-heap)
func pop():
    if heap.size() == 0:
        return null
    var root = heap[0]["value"]
    heap[0] = heap[heap.size() - 1]
    heap.pop_back()
    _heapify_down(0)
    return root

# Peek at the value with the lowest priority without removing it
func peek():
    if heap.size() == 0:
        return null
    return heap[0]["value"]

# Check if the heap is empty
func is_empty() -> bool:
    return heap.size() == 0


# Internal: Restore the heap property by moving a node up
func _heapify_up(index):
    while index > 0:
        var parent = (index - 1) / 2 #TODO: 
        if heap[index]["priority"] < heap[parent]["priority"]:
            # Swap heap[index] and heap[parent]
            var temp = heap[index]
            heap[index] = heap[parent]
            heap[parent] = temp
            # Move up to the parent index
            index = parent
        else:
            break

# Internal: Restore the heap property by moving a node down
func _heapify_down(index):
    var size = heap.size()
    while true:
        var left = 2 * index + 1
        var right = 2 * index + 2
        var smallest = index

        # Check if the left child has a smaller priority
        if left < size and heap[left]["priority"] < heap[smallest]["priority"]:
            smallest = left

        # Check if the right child has a smaller priority
        if right < size and heap[right]["priority"] < heap[smallest]["priority"]:
            smallest = right

        # If the smallest is still the current index, the heap property is satisfied
        if smallest == index:
            break

        # Swap heap[index] and heap[smallest]
        var temp = heap[index]
        heap[index] = heap[smallest]
        heap[smallest] = temp

        # Move down to the smallest child
        index = smallest
