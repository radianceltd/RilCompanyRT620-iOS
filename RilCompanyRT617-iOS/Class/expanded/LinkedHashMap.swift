//
//  LinkedHashMap.swift
//  TMW041RT
//
//  Created by RND on 2023/5/31.
//

class LinkedHashMap<K: Hashable, V> {
    var list: [V] = []
    var hashMap: [K: Int] = [:]
    
    func put(key: K, value: V) -> [Int] {
        if let index = hashMap[key] {
            list[index] = value
            return [index, 0]
        }
        
        let index = list.count
        list.append(value)
        hashMap[key] = index
        return [index, 1]
    }
    
    func put1(key: K, value: V) -> Void {
        if let index = hashMap[key] {
            list[index] = value
            let q = [index, 0]
            print(q)
        }
        
        let index = list.count
        list.append(value)
        hashMap[key] = index
        let q = [index, 1]
        print(q)
    }
    
    func get(index: Int) -> V {
        return list[index]
    }
    
    // 通过key获取value
    func get(key: K) -> V? {
        if let index = hashMap[key] {
            return list[index]
        }
        return nil
    }
    
    // 通过key获取索引
    func getIndex(key: K) -> Int? {
        return hashMap[key]
    }
    
    // 通过key获取value和索引
    func getWithIndex(key: K) -> (value: V, index: Int)? {
        if let index = hashMap[key] {
            return (list[index], index)
        }
        return nil
    }
    
    // 移除指定key的元素
    func remove(key: K) -> V? {
        guard let indexToRemove = hashMap[key] else {
            return nil
        }
        
        // 保存要移除的值
        let removedValue = list[indexToRemove]
        
        // 从list中移除元素
        list.remove(at: indexToRemove)
        
        // 从hashMap中移除该key
        hashMap.removeValue(forKey: key)
        
        // 更新hashMap中所有索引大于被移除索引的元素
        for (existingKey, existingIndex) in hashMap {
            if existingIndex > indexToRemove {
                hashMap[existingKey] = existingIndex - 1
            }
        }
        
        return removedValue
    }
    
    // 移除指定索引的元素
    func remove(at index: Int) -> V? {
        guard index >= 0 && index < list.count else {
            return nil
        }
        
        // 找到对应的key
        var keyToRemove: K?
        for (key, valueIndex) in hashMap {
            if valueIndex == index {
                keyToRemove = key
                break
            }
        }
        
        guard let key = keyToRemove else {
            return nil
        }
        
        // 保存要移除的值
        let removedValue = list[index]
        
        // 从list中移除元素
        list.remove(at: index)
        
        // 从hashMap中移除该key
        hashMap.removeValue(forKey: key)
        
        // 更新hashMap中所有索引大于被移除索引的元素
        for (existingKey, existingIndex) in hashMap {
            if existingIndex > index {
                hashMap[existingKey] = existingIndex - 1
            }
        }
        
        return removedValue
    }
    
    // 移除所有元素
    func removeAll() {
        list.removeAll()
        hashMap.removeAll()
    }
    
    // 判断是否包含指定key
    func contains(key: K) -> Bool {
        return hashMap[key] != nil
    }
    
    // 获取所有key
    func keys() -> [K] {
        // 按照插入顺序返回key
        var keys: [K] = []
        for i in 0..<list.count {
            for (key, index) in hashMap {
                if index == i {
                    keys.append(key)
                    break
                }
            }
        }
        return keys
    }
    
    // 获取所有value
    func values() -> [V] {
        return list
    }
    
    // 获取所有键值对（按插入顺序）
    func entries() -> [(key: K, value: V)] {
        var entries: [(key: K, value: V)] = []
        for i in 0..<list.count {
            for (key, index) in hashMap {
                if index == i {
                    entries.append((key, list[i]))
                    break
                }
            }
        }
        return entries
    }
    
    func size() -> Int {
        return list.count
    }
    
    func clear() {
        list.removeAll()
        hashMap.removeAll()
    }
    
    // 判断是否为空
    var isEmpty: Bool {
        return list.isEmpty
    }
    
    // 下标访问
    subscript(key: K) -> V? {
        get {
            return get(key: key)
        }
        set {
            if let value = newValue {
                _ = put(key: key, value: value)
            } else {
                _ = remove(key: key)
            }
        }
    }
    
    // 通过索引下标访问
    subscript(index: Int) -> V? {
        get {
            guard index >= 0 && index < list.count else {
                return nil
            }
            return list[index]
        }
    }
}
