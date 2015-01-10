$pm = 0.01
$cluster_num = 20
$result = nil
 
def gen_rands(n, lb, rb)
  rands = []
  n.times do
    r = rand(lb..rb)
    rands << r
  end
  rands
end
 
def gen_rands_arr(arr_num, n, lb, rb)
  rands_arr = []
  arr_num.times do 
    rands_arr << gen_rands(n, lb, rb)
  end
  rands_arr
end
 
def fit(sum, all_rands)
  total_p = 0.0
  curr_p_arr = []
  all_rands.each do |rands|
    curr_p = 0.0;
    rands.each { |r| curr_p += r }
    delta = sum-curr_p
    if delta == 0
      $result=rands
      return
    end
    curr_p = 1.0/(delta)
    curr_p = curr_p.abs
    curr_p_arr << curr_p
    total_p += curr_p
  end
 
  fit_arr = []
  fit_arr << curr_p_arr[0]/total_p
  curr_p_arr.each_index do |i|
    next if i == 0
    fit_arr << fit_arr[i-1] + curr_p_arr[i]/total_p
  end
 
  fit_arr
end
 
def ga(sum, n, lb, rb)
  rands_arr = gen_rands_arr($cluster_num, n, lb, rb)
  fit_arr = fit(sum, rands_arr)
  while $result.nil?
    fit_arr = fit(sum, rands_arr)
    return unless $result.nil?
    selector_arr = []
    $cluster_num.times do
      selector_arr << rand()
    end
 
    selected_rands_indexs = Array.new($cluster_num, 0)
    selector_arr.each do |s|
      # binary search
      low = 0
      high = fit_arr.size
      while low <= high
        middle = (low+high)/2
        if fit_arr[middle] >= s
          high = middle-1
        else
          low = middle+1
        end
      end
      selected_rands_indexs[low] += 1
    end
 
    next_gen_rands_arr = []
    k = 0
    while k < $cluster_num do
      i = 0
      while selected_rands_indexs[i] == 0
        i += 1
      end
      selected_rands_indexs[i] -= 1
 
      j = i+1
      while selected_rands_indexs[j] == 0
        j += 1
      end
      j = i if j == $cluster_num
      selected_rands_indexs[j] -= 1
 
      next_gen_rands1 = []
      next_gen_rands2 = []
      # 随机交叉点
      r1 = rand(0..n-1)
      r2 = rand(0..n-1)
      if r1 > r2
        tmp = r1
        r1 = r2
        r2 = tmp
      end 
 
      for ii in 0..(r1-1) do
        next_gen_rands1[ii] = rands_arr[i][ii]
        next_gen_rands2[ii] = rands_arr[j][ii]
      end
      for jj in (r2+1)..(n-1) do
        next_gen_rands1[jj] = rands_arr[i][jj]
        next_gen_rands2[jj] = rands_arr[j][jj]
      end
      # 交换基因
      for kk in r1..r2 do 
        next_gen_rands1[kk] = rands_arr[j][kk]
        next_gen_rands2[kk] = rands_arr[i][kk]
      end
      # 忽略修复重复基因
 
      #新种群
      next_gen_rands_arr[k] = next_gen_rands1
      next_gen_rands_arr[k+1] = next_gen_rands2
      k+=2
    end
 
    next_gen_rands_arr.each do |r|
      #突变
      pm = rand()
      if pm < $pm
        #发生突变
        #突变点
        pi = rand(0..n-1)
        new_rand = rand(lb..rb)
        r[pi] = new_rand
      end
    end
    rands_arr = next_gen_rands_arr
 
    rands_arr.each do |rands|
      curr_p=0
      rands.each { |r| curr_p += r }
      delta = sum-curr_p
      if delta == 0
        $result=rands
        return
      end
    end
  end
end
 
ga 80000, 100, 4, 1300
p $result.sort

