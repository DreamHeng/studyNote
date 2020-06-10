# Java并发编程

## 一.并发基础

### 1.Synchronized

​	Synchronized是java中实现同步的一种机制，是用来保证内存可见性和操作原子性的，它的实现基础是java中的任何一个对象都可以当做锁。

​	Synchronized的使用形式有三种：

- 实现在普通同步方法，锁对象是当前实例对象；

- 实现在静态同方法，锁对象是对象的类对象，对此类的所有实例对象都生效；

- 实现在同步代码块，锁对象是小括号里面的对象。

​	Synchronized在JVM中的实现原理是基于进入和退出Monitor对象来实现的，代码块同步是通过monitorenter指令和monitorexit指令来实现的，方法同步也可以这样实现。在代码编译后monitorenter指令会插入到同步代码块的开始位置，monitorexit指令会在代码块结束和异常位置插入。

​	根据JVM规范，在执行monitorenter指令的时候，首先需要去尝试获取对象的锁，如果这个对象没有被锁定，或者被本线程获取到，那就在这个锁的计数器上加1，然后在执行，当再次遇到monitorenter时，再在计数器加1，这就是可重入性，当执行到monitorexit时，计数器减1；另一个线程在获取此对象锁时，如果计数器不为0则代表此对象已经被锁定，该线程进入阻塞状态，等待其它线程释放锁然后再获取再继续执行，中间不能干其它事。

​	Synchronized用的锁是存在Java对象头里的。

（待深入研究。。。）

### 2.原子操作和CAS

​	原子(Atomic)本意是指“不能被进一步分割的最小粒子”，原子操作(Atomic operation)就是指不可被中断的一个或一系列操作。Java中可以通过锁和CAS来实现原子操作。并发编程的三要素就是原子性、可见性、有序性。

​	CAS（compare and Swap）比较并替换，是计算机科学中一种实现多线程原子操作的指令，在java并发编程中，原子性主要就是由CAS操作来保证的。CAS操作有三个操作值，一个内存值(内存位置)，一个旧值，一个新值，在进行写入操作的时候先比较旧值是否有变化，没变化则赋新值，有变化则不赋。

​	JUC包下的atomic类都是通过CAS来实现的，我们观察atomic包的任意一个类的源码，可以看到这些类在进行任意一个操作的时候，都会调用C++对象Unsafe的一个对应方法，参数分别为（对象、内存地址、新值、旧值），然后在Unsafe的方法实现里，是使用处理器的cmpxchgl指令来实现，在多核情况下还会在cmpxchgl前生成一个lock指令前缀。

#### 2.1.Java实现原子操作的方式

- **使用循环CAS实现原子操作**，就是循环进行CAS操作直到成功为止，JUC的atomic包下的一些类就是使用这种形式支持原子操作，这种方式的实现会有三个问题：
  - **ABA问题**，CAS操作的时候会比较原先的值，如果一个线程在取的时候值是A，经过另外的线程操作后变成B，又变成A，那么这个线程在放入的时候会以为没经过变化，直接置换新值，这样可能会有问题（具体有没有问题或影响需要看具体的业务）。从jdk1.5开始atomic包下有个AtomicStampedReference类解决了这个问题，它是在值的基础上加上了版本号标志，如刚才那个就变成了1A->2B->3A.
  - **循环时间长开销大**，CAS操作是在进行不停的自旋，自旋是会有可能失败的，如果一直失败，那就会给CPU很大的压力；
  - **只能保证一个共享变量的原子操作**，通过CAS的实现我们可以看出来只支持一个变量，多个变量还是需要用synchronized。从jdk1.5开始，atomic包下提供了AtomicReference类来帮助我们将多个变量放在一个对象中进行CAS操作。

- **使用锁机制实现原子操作**，锁机制保证了只有获得锁的线程才能对锁定的内存区域进行操作。JVA内部实现了很多锁，有偏向锁、轻量级锁和互斥锁，其实，除了偏向锁，JVM实现锁的方式都用了CAS操作，即一个线程进入同步块的时候使用CAS机制获取锁，当它退出同步块的时候使用CAS机制释放锁。

2.2.CAS汇编级别实现源码分析（待深入研究。。。）

## 二.并发工具

### 1.ConcurrentHashMap

​	ConcurrentHashMap是jdk1.5后推出的JUC下线程安全的HashMap，与HashTable实现线程安全的方法不同，ConcurrentHashMap初始保证线程安全的手段是分段锁，即将HashMap底层的数组分为几个小数组，分段进行加锁，在jdk1.8时，保证安全的手段有了改变，是使用CAS+分段锁的方式，即HashMap数组的每个位置都是一个单独的CAS操作，每个位置执行时单独加锁，进行链表+红黑树操作。上述保证安全的手段都是加锁在put操作。

#### 1.1.jdk1.7的分段锁

​	ConcurrentHashMap是由Segment数组结构和HashEntry数组结构组成。Segment是一种可重入锁ReentrantLock，在ConcurrentHashMap里扮演锁的角色，HashEntry则用于存储键值对数据。一个ConcurrentHashMap里包含一个Segment数组，Segment的结构和HashMap类似，是一种数组和链表结构， 一个Segment里包含一个HashEntry数组，每个HashEntry是一个链表结构的元素， 每个Segment守护着一个HashEntry数组里的元素，当对HashEntry数组的数据进行修改时，必须首先获得它对应的Segment锁。

#### 1.2.jdk1.8

​	从源码中我们可以分析：

- 从第二行看出ConcurrentHashMap不允许key为null。
- 从第五行可以看出，循环利用CAS更新数组的元素，直到成功为止，
- 第九行，判断数组的index下没有元素，利用CAS机制添加元素
- 第十八行，锁住头节点，在进行链表或红黑树操作。

```java
    final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();
        int hash = spread(key.hashCode());
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
                if (casTabAt(tab, i, null,
                             new Node<K,V>(hash, key, value, null)))
                    break;                   // no lock when adding to empty bin
            }
            else if ((fh = f.hash) == MOVED)
                tab = helpTransfer(tab, f);
            else {
                V oldVal = null;
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    oldVal = e.val;
                                    if (!onlyIfAbsent)
                                        e.val = value;
                                    break;
                                }
                                Node<K,V> pred = e;
                                if ((e = e.next) == null) {
                                    pred.next = new Node<K,V>(hash, key,
                                                              value, null);
                                    break;
                                }
                            }
                        }
                        else if (f instanceof TreeBin) {
                            Node<K,V> p;
                            binCount = 2;
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                           value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                        }
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        addCount(1L, binCount);
        return null;
    }
```

