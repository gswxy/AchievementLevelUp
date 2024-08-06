<h1>AchievementLevelUp Script</h1>
<h2>概述</h2>
<p>本脚本用于 AzerothCore 服务端，提供了一个根据玩家成就数量变化进行等级提升的机制。脚本包括配置项、概率计算、日志记录和事件处理等功能。</p>
<h2>功能描述</h2>
<h3>配置项</h3>
<ul>
<li><strong>CHECK_INTERVAL</strong>: 检查玩家成就数量变化的间隔时间，单位为毫秒，默认值为60000（即1分钟）。</li>
<li><strong>MIN_LEVEL</strong>: 允许参与成就升级的最低等级，默认为10。</li>
<li><strong>MAX_LEVEL</strong>: 允许参与成就升级的最高等级，默认为79。</li>
<li><strong>MAX_ACCUMULATED_PROBABILITY</strong>: 累加概率的最大值，默认值为1。</li>
</ul>
<h3>基础概率</h3>
<ul>
<li><strong>baseProbability</strong>: 基础概率，默认值为0.3。</li>
</ul>
<h3>概率计算公式</h3>
<ul>
<li>
<p><strong>衰减系数</strong>: <code>k</code> 的计算公式如下：</p>
<pre class="code-block-wrapper"><div class="code-block-header"><span class="code-block-header__lang"></span><span class="code-block-header__copy"></span></div><code class="hljs code-block-body "><span class="hljs-attribute">k</span> <span class="hljs-operator">=</span> math.log(<span class="hljs-number">10</span>) / (MAX_LEVEL - MIN_LEVEL)
</code></pre>
</li>
<li>
<p><strong>升级概率</strong>: 使用指数衰减函数计算升级概率：</p>
<pre class="code-block-wrapper"><div class="code-block-header"><span class="code-block-header__lang"></span><span class="code-block-header__copy"></span></div><code class="hljs code-block-body "><span class="hljs-attribute">probability</span> <span class="hljs-operator">=</span> baseProbability * math.exp(-k * (level - MIN_LEVEL))
</code></pre>
<p>其中：</p>
<ul>
<li><code>baseProbability</code> 是基础概率。</li>
<li><code>level</code> 是玩家当前的等级。</li>
<li><code>k</code> 是衰减系数。</li>
</ul>
</li>
</ul>
<h3>例子</h3>
<p>假设 <code>MIN_LEVEL = 10</code>，<code>MAX_LEVEL = 79</code>，<code>baseProbability = 0.3</code>。如果玩家当前等级为20，衰减系数 <code>k</code> 计算如下：</p>
<pre class="code-block-wrapper"><div class="code-block-header"><span class="code-block-header__lang"></span><span class="code-block-header__copy"></span></div><code class="hljs code-block-body "><span class="hljs-attribute">k</span> = math.log(<span class="hljs-number">10</span>) / (<span class="hljs-number">79</span> - <span class="hljs-number">10</span>) ≈ <span class="hljs-number">0</span>.<span class="hljs-number">0332</span>
</code></pre>
<p>则玩家的升级概率为：</p>
<pre class="code-block-wrapper"><div class="code-block-header"><span class="code-block-header__lang"></span><span class="code-block-header__copy"></span></div><code class="hljs code-block-body "><span class="hljs-attribute">probability</span> = <span class="hljs-number">0</span>.<span class="hljs-number">3</span> * math.exp(-<span class="hljs-number">0</span>.<span class="hljs-number">0332</span> * (<span class="hljs-number">20</span> - <span class="hljs-number">10</span>)) ≈ <span class="hljs-number">0</span>.<span class="hljs-number">215</span>
</code></pre>
<h3>累加概率机制</h3>
<p>玩家在多次检查中未升级的情况下，系统会累积其概率。例如：</p>
<ul>
<li>初始累加概率为0</li>
<li>第一次检查后概率为0.215，未升级</li>
<li>累加概率为0.215</li>
<li>第二次检查时，总概率为 <code>0.215 + 0.215 = 0.43</code></li>
</ul>
<p>如果总概率超过 <code>MAX_ACCUMULATED_PROBABILITY</code>，则限制在最大值：</p>
<pre class="code-block-wrapper"><div class="code-block-header"><span class="code-block-header__lang"></span><span class="code-block-header__copy"></span></div><code class="hljs code-block-body "><span class="hljs-attr">totalProbability</span> = min(totalProbability, <span class="hljs-number">1</span>)
</code></pre>
<h3>日志记录</h3>
<p>当玩家升级或未能升级时，系统将记录相关信息到日志文件 <code>AchievementLevelUp.log</code>。日志格式如下：</p>
<pre class="code-block-wrapper"><div class="code-block-header"><span class="code-block-header__lang"></span><span class="code-block-header__copy"></span></div><code class="hljs code-block-body ">[<span class="hljs-string">时间戳</span>] <span class="hljs-attr">PlayerID:</span> <span class="hljs-string">玩家ID,</span> <span class="hljs-attr">CurrentLevel:</span> <span class="hljs-string">当前等级,</span> <span class="hljs-attr">NewLevel:</span> <span class="hljs-string">新等级,</span> <span class="hljs-attr">Probability:</span> <span class="hljs-string">升级概率</span>
</code></pre>
<h3>事件处理</h3>
<ul>
<li><strong>OnPlayerLogin</strong>: 玩家登录时注册检查事件，并初始化玩家的成就数量和累加概率。</li>
<li><strong>OnPlayerLogout</strong>: 玩家登出时移除相关事件，并清除玩家数据。</li>
</ul>
<h2>使用说明</h2>
<p>将脚本放置于服务器的 <code>lua_scripts</code> 目录下，并确保脚本路径正确。玩家登录后，脚本将开始根据成就数量变化自动检查和更新玩家等级。</p>
