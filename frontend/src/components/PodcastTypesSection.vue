<script setup>
// 播客类型卡片区，使用翻页玻璃卡片效果
</script>

<template>
  <section class="py-20 px-6 container mx-auto">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
      <!-- 知识类播客 -->
      <div class="flip-container">
        <div class="flip-inner">
          <div class="flip-front glass-card">
            <div class="text-[#9DACCC] mb-4 font-mono">01 / KNOWLEDGE</div>
            <h3 class="text-3xl font-bold mb-4">知识类播客</h3>
            <p class="text-[#9DACCC] leading-relaxed">
              追求"信噪比"。针对深度访谈与科普教学，通过高强度压缩逻辑重复与长停顿，确保每一分钟都是干货。
            </p>
            <div class="mt-8 flex gap-2">
              <span
                class="text-[10px] px-2 py-1 border border-[#485F88] rounded text-[#C0C9DB]"
              >
                MODERNBERT-BASE
              </span>
              <span
                class="text-[10px] px-2 py-1 border border-[#485F88] rounded text-[#C0C9DB]"
              >
                SHOWNOTES
              </span>
            </div>
          </div>
          <div class="flip-back glass-card">
            <h4 class="text-xl font-bold mb-4">AI 剪辑策略</h4>
            <ul class="text-sm space-y-3 text-[#C0C9DB]">
              <li>• 文本化编辑 (Text-based Editing)</li>
              <li>• 跨段落语义关联分析 (8192 Token)</li>
              <li>• 自动生成结构化思维导图</li>
              <li>• 关键观点热图检测</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- 陪伴类播客 -->
      <div class="flip-container">
        <div class="flip-inner">
          <div class="flip-front glass-card">
            <div class="text-[#9DACCC] mb-4 font-mono">02 / COMPANION</div>
            <h3 class="text-3xl font-bold mb-4">陪伴类播客</h3>
            <p class="text-[#9DACCC] leading-relaxed">
              追求"人味"。识别主播思考时的微妙停顿与笑声，利用自适应交叉淡化保持语速律动，拒绝"AI读稿感"。
            </p>
            <div class="mt-8 flex gap-2">
              <span
                class="text-[10px] px-2 py-1 border border-[#485F88] rounded text-[#C0C9DB]"
              >
                VOICECRAFT
              </span>
              <span
                class="text-[10px] px-2 py-1 border border-[#485F88] rounded text-[#C0C9DB]"
              >
                EMOTION-LLAMA
              </span>
            </div>
          </div>
          <div class="flip-back glass-card">
            <h4 class="text-xl font-bold mb-4">AI 剪辑策略</h4>
            <ul class="text-sm space-y-3 text-[#C0C9DB]">
              <li>• 情绪保留逻辑 (保留意境留白)</li>
              <li>• 自适应交叉淡化 (Adaptive Cross-fade)</li>
              <li>• 缺失语素的情感克隆修复</li>
              <li>• 数字人肖像情感张力生成</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
