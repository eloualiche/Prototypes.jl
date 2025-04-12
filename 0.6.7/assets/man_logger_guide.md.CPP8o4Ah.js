import{_ as i,c as a,o as n,az as t}from"./chunks/framework.B6Dc99K_.js";const d=JSON.parse('{"title":"Logging","description":"","frontmatter":{},"headers":[],"relativePath":"man/logger_guide.md","filePath":"man/logger_guide.md","lastUpdated":null}'),l={name:"man/logger_guide.md"};function e(h,s,p,k,r,g){return n(),a("div",null,s[0]||(s[0]=[t(`<h1 id="logging" tabindex="-1">Logging <a class="header-anchor" href="#logging" aria-label="Permalink to &quot;Logging&quot;">​</a></h1><p>The function <code>custom_logger</code> is a wrapper over the <code>Logging.jl</code> and <code>LoggingExtras.jl</code> libraries. I made them such that I could fine tune the type of log I use repeatedly across projects.</p><p>The things I find most useful:</p><ol><li><p>four different log files for each different level of logging from <em>error</em> to <em>debug</em></p></li><li><p>pretty (to me) formatting for stdout but also an option to have <code>log4j</code> style formatting in the files</p></li><li><p>filtering out messages of verbose packages (<code>TranscodingStreams</code>, etc...) which sometimes slows down julia because of excessive logging.</p></li></ol><p>There are still a few things that might be useful down the line: (1) a catch-all log file where filters do not apply; (2) filtering out specific functions of packages;</p><p>Overall this is working fine for me.</p><h2 id="Basic-usage" tabindex="-1">Basic usage <a class="header-anchor" href="#Basic-usage" aria-label="Permalink to &quot;Basic usage {#Basic-usage}&quot;">​</a></h2><p>Say at the beginning of a script you would have something like:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Prototypes</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">custom_logger</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;/tmp/log_test&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">; </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    filtered_modules_all</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">[</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">:StatsModels</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">:TranscodingStreams</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">:Parquet2</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">], </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    create_log_files</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    overwrite</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    log_format </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> :log4j</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">);</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">┌ Info</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Creating four different files </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">for</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> logging </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">│  ⮑  </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">tmp</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log_test_error</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">│      </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">tmp</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log_test_warn</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">│      </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">tmp</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log_test_info</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">└      </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">tmp</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log_test_debug</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log</span></span></code></pre></div><p>The REPL will see all messages above debug level:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @error</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an error level message&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">┌ [</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">08</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">28</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">08</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 2025</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">02</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">12</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] ERROR </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">|</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  @ Main[REPL[</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">17</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">1</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">└ This is an error level message</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @warn</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an warn level message&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">┌ [</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">08</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">28</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">08</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 2025</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">02</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">12</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] WARN  </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">|</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  @ Main[REPL[</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">18</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">1</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">└ This is an warn level message</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @info</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an info level message&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">┌ [</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">08</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">28</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">08</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 2025</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">02</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">12</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] INFO  </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">|</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  @ Main[REPL[</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">19</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">1</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">└ This is an info level message</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @debug</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an debug level message&quot;</span></span></code></pre></div><p>Then each of the respective log-levels will be redirected to the individual files and if the log4j option was specified they will look like something like this</p><div class="language-log4j vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">log4j</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>2025-02-12 08:28:08 ERROR Main[REPL[17]:1] - This is an error level message</span></span>
<span class="line"><span>2025-02-12 08:28:08 WARN  Main[REPL[18]:1] - This is an warn level message</span></span>
<span class="line"><span>2025-02-12 08:28:08 INFO  Main[REPL[19]:1] - This is an info level message</span></span>
<span class="line"><span>2025-02-12 08:28:08 DEBUG Main[REPL[20]:1] - This is an debug level message</span></span></code></pre></div><h2 id="options" tabindex="-1">Options <a class="header-anchor" href="#options" aria-label="Permalink to &quot;Options&quot;">​</a></h2><h3 id="formatting" tabindex="-1">Formatting <a class="header-anchor" href="#formatting" aria-label="Permalink to &quot;Formatting&quot;">​</a></h3><p>The <code>log_format</code> is <code>log4j</code> by default (only for the files). The only other option for now is <code>pretty</code> which uses the format I wrote for the REPL; note that it is a little cumbersome for files especially since you have to make sure your editor has the ansi interpreter on.</p><h3 id="files" tabindex="-1">Files <a class="header-anchor" href="#files" aria-label="Permalink to &quot;Files&quot;">​</a></h3><p>The default is to create one file for each level. There is an option to only create one file for each level and keep things a little tidier in your directories:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> custom_logger</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;/tmp/log_test&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">;  </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    create_log_files</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, overwrite</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">true</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, log_format </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> :log4j</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">);</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">┌ [</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">08</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">37</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">03</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> 2025</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">02</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">-</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">12</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">] INFO  </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">|</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  @ Prototypes[</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Users</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">loulou</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Dropbox</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">projects_code</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">julia_packages</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Prototypes</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">src</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">CustomLogger</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">jl</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">44</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">]</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">│ Only one sink provided </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">...</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">└   All logs will be written without differentiation on </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">tmp</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">/</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">log_test</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @error</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an error level message&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> </span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @warn</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an warn level message&quot;</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @info</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an info level message&quot;</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @debug</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an debug level message&quot;</span></span></code></pre></div><p>And then the file <code>/tmp/log_test</code> has the following:</p><div class="language-log4j vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">log4j</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>2025-02-12 08:37:29 ERROR Main[REPL[22]:1] - This is an error level message</span></span>
<span class="line"><span>2025-02-12 08:37:29 WARN  Main[REPL[23]:1] - This is an warn level message</span></span>
<span class="line"><span>2025-02-12 08:37:29 INFO  Main[REPL[24]:1] - This is an info level message</span></span>
<span class="line"><span>2025-02-12 08:37:29 DEBUG Main[REPL[25]:1] - This is an debug level message</span></span></code></pre></div><p>Now imagine you want to keep the same log file but for a different script. You can use the same logger option with the <code>overwrite=false</code> option:</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> custom_logger</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;/tmp/log_test&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">;  </span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    create_log_files</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, overwrite</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">false</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, log_format </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> :log4j</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">);</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> @error</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;This is an error level message from a different script and new logger&quot;</span></span></code></pre></div><h3 id="filtering" tabindex="-1">Filtering <a class="header-anchor" href="#filtering" aria-label="Permalink to &quot;Filtering&quot;">​</a></h3><ul><li><p><code>filtered_modules_specific::Vector{Symbol}=nothing</code>: which modules do you want to filter out of logging (only for info and stdout) Some packages just write too much log ... filter them out but still be able to check them out in other logs</p></li><li><p><code>filtered_modules_all::Vector{Symbol}=nothing</code>: which modules do you want to filter out of logging (across all logs) Examples could be TranscodingStreams (noticed that it writes so much to logs that it sometimes slows down I/O)</p></li></ul><h2 id="other" tabindex="-1">Other <a class="header-anchor" href="#other" aria-label="Permalink to &quot;Other&quot;">​</a></h2><p>For <code>log4j</code> I do modify the message string to fit on one line. You will find that the &quot;\\n&quot; is now replaced by &quot; | &quot;; I guess I could have an option for which character delimitates lines, but this seems too fussy.</p><p>I am trying to have a path shortener that would allow to reduce the path of the function to a fixed size. The cost is that path will no longer be &quot;clickable&quot; but we would keep things tidy as messages will all start at the same column. (see the <code>shorten_path_str</code> function).</p>`,28)]))}const E=i(l,[["render",e]]);export{d as __pageData,E as default};
