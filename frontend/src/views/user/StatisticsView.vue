<template>
  <div class="p-6 bg-gray-50 min-h-screen">
    <h1 class="text-3xl font-bold mb-6 text-gray-800">数据统计分析</h1>

    <!-- 创作效率 -->
    <section class="mb-8">
      <h2 class="text-2xl font-semibold mb-4 text-gray-700">创作效率</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <!-- 累计剪辑时长 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">累计剪辑时长 (小时)</h3>
          <div ref="totalEditingTimeChart" class="h-64"></div>
        </div>
        <!-- 累计处理音频条数 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">累计处理音频条数</h3>
          <div ref="totalAudioProcessedChart" class="h-64"></div>
        </div>
        <!-- AI 剪辑节省时长 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">AI 剪辑节省时长 (小时)</h3>
          <div ref="aiTimeSavedChart" class="h-64"></div>
        </div>
        <!-- 平均素材检索耗时 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">平均素材检索耗时 (分钟/条)</h3>
          <div ref="avgMaterialSearchTimeChart" class="h-64"></div>
        </div>
      </div>
    </section>

    <!-- 内容产出 -->
    <section class="mb-8">
      <h2 class="text-2xl font-semibold mb-4 text-gray-700">内容产出</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
        <!-- 各专辑/栏目剪辑数量分布 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">各专辑/栏目剪辑数量分布</h3>
          <div ref="albumDistributionChart" class="h-72"></div>
        </div>
        <!-- 内容状态分布 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">内容状态分布</h3>
          <div ref="contentStatusChart" class="h-72"></div>
        </div>
      </div>
    </section>

    <!-- 剪辑质量 -->
    <section class="mb-8">
      <h2 class="text-2xl font-semibold mb-4 text-gray-700">剪辑质量</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- 冗余内容剔除率 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">冗余内容剔除率 (%)</h3>
          <div ref="redundancyRemovalRateChart" class="h-64"></div>
        </div>
        <!-- 音频修复次数 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">音频修复次数</h3>
          <div ref="audioRepairCountChart" class="h-64"></div>
        </div>
        <!-- 跨平台分发物料生成数量 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">跨平台分发物料生成数量</h3>
          <div ref="crossPlatformMaterialChart" class="h-64"></div>
        </div>
      </div>
    </section>

    <!-- 行为习惯 -->
    <section class="mb-8">
      <h2 class="text-2xl font-semibold mb-4 text-gray-700">行为习惯</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- 高频剪辑时段分布 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">高频剪辑时段分布</h3>
          <div ref="editingTimeDistributionChart" class="h-64"></div>
        </div>
        <!-- 常用剪辑功能使用频次 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">常用剪辑功能使用频次</h3>
          <div ref="commonFeaturesChart" class="h-64"></div>
        </div>
        <!-- 累计保存的素材片段数量 -->
        <div class="bg-white p-4 rounded-lg shadow">
          <h3 class="text-lg font-medium text-gray-600 mb-2">累计保存的素材片段数量</h3>
          <div ref="savedClipsChart" class="h-64"></div>
        </div>
      </div>
    </section>

    <!-- 更多模块可以在此添加 -->

  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue';
import * as echarts from 'echarts';

// Refs for chart containers
const totalEditingTimeChart = ref(null);
const totalAudioProcessedChart = ref(null);
const aiTimeSavedChart = ref(null);
const avgMaterialSearchTimeChart = ref(null);
const albumDistributionChart = ref(null);
const contentStatusChart = ref(null);

// Refs for Editing Quality charts
const redundancyRemovalRateChart = ref(null);
const audioRepairCountChart = ref(null);
const crossPlatformMaterialChart = ref(null);

// Refs for Behavioral Habits charts
const editingTimeDistributionChart = ref(null);
const commonFeaturesChart = ref(null);
const savedClipsChart = ref(null);

onMounted(() => {
  // Wait for the tab switch animation to complete before rendering charts
  setTimeout(() => {
    nextTick(() => {
      initCharts();
    });
  }, 100); // A small delay to ensure containers are sized correctly
});

function initCharts() {
  // 创作效率
  initTotalEditingTimeChart();
  initTotalAudioProcessedChart();
  initAiTimeSavedChart();
  initAvgMaterialSearchTimeChart();

  // 内容产出
  initAlbumDistributionChart();
  initContentStatusChart();

  // 剪辑质量
  initRedundancyRemovalRateChart();
  initAudioRepairCountChart();
  initCrossPlatformMaterialChart();

  // 行为习惯
  initEditingTimeDistributionChart();
  initCommonFeaturesChart();
  initSavedClipsChart();
}

// 1. 累计剪辑时长
function initTotalEditingTimeChart() {
  const chart = echarts.init(totalEditingTimeChart.value);
  const option = {
    series: [
      {
        type: 'gauge',
        center: ['50%', '60%'],
        startAngle: 200,
        endAngle: -20,
        min: 0,
        max: 1000,
        splitNumber: 10,
        itemStyle: {
          color: '#FF6B9D'
        },
        progress: {
          show: true,
          width: 30
        },
        pointer: {
          show: false
        },
        axisLine: {
          lineStyle: {
            width: 30
          }
        },
        axisTick: {
          distance: -45,
          splitNumber: 5,
          lineStyle: {
            width: 2,
            color: '#999'
          }
        },
        splitLine: {
          distance: -52,
          length: 14,
          lineStyle: {
            width: 3,
            color: '#999'
          }
        },
        axisLabel: {
          distance: -20,
          color: '#999',
          fontSize: 20
        },
        anchor: {
          show: false
        },
        title: {
          show: false
        },
        detail: {
          valueAnimation: true,
          width: '60%',
          lineHeight: 40,
          borderRadius: 8,
          offsetCenter: [0, '-15%'],
          fontSize: 30,
          fontWeight: 'bolder',
          formatter: '{value} 小时',
          color: 'inherit'
        },
        data: [
          {
            value: 785
          }
        ]
      }
    ]
  };
  chart.setOption(option);
}

// 2. 累计处理音频条数
function initTotalAudioProcessedChart() {
    const chart = echarts.init(totalAudioProcessedChart.value);
    const option = {
        xAxis: {
            type: 'category',
            data: ['一月', '二月', '三月', '四月', '五月', '六月']
        },
        yAxis: {
            type: 'value'
        },
        series: [{
            data: [12, 23, 35, 48, 52, 60],
            type: 'bar',
            itemStyle: {
                color: '#C084FC'
            }
        }],
        grid: {
            left: '3%',
            right: '4%',
            bottom: '3%',
            containLabel: true
        },
        tooltip: {
            trigger: 'axis'
        }
    };
    chart.setOption(option);
}

// 3. AI 剪辑节省时长
function initAiTimeSavedChart() {
    const chart = echarts.init(aiTimeSavedChart.value);
    const option = {
        xAxis: {
            type: 'category',
            data: ['人工剪辑', 'AI剪辑']
        },
        yAxis: {
            type: 'value',
            name: '小时'
        },
        series: [{
            data: [120, 45],
            type: 'bar',
            itemStyle: {
                color: (params) => (params.name === 'AI剪辑' ? '#FF6B9D' : '#C084FC')
            }
        }],
        grid: {
            left: '3%',
            right: '4%',
            bottom: '3%',
            containLabel: true
        },
        tooltip: {
            trigger: 'axis'
        }
    };
    chart.setOption(option);
}

// 4. 平均素材检索耗时
function initAvgMaterialSearchTimeChart() {
    const chart = echarts.init(avgMaterialSearchTimeChart.value);
    const option = {
        xAxis: {
            type: 'category',
            data: ['第一周', '第二周', '第三周', '第四周', '第五周']
        },
        yAxis: {
            type: 'value',
            name: '分钟/条'
        },
        series: [{
            data: [5.2, 4.5, 3.8, 3.1, 2.5],
            type: 'line',
            smooth: true,
            itemStyle: {
                color: '#FF6B9D'
            }
        }],
        grid: {
            left: '3%',
            right: '4%',
            bottom: '3%',
            containLabel: true
        },
        tooltip: {
            trigger: 'axis'
        }
    };
    chart.setOption(option);
}

// 5. 各专辑/栏目剪辑数量分布
function initAlbumDistributionChart() {
    const chart = echarts.init(albumDistributionChart.value);
    const option = {
        tooltip: {
            trigger: 'item'
        },
        legend: {
            top: '5%',
            left: 'center'
        },
        series: [
            {
                name: '专辑分布',
                type: 'pie',
                radius: ['40%', '70%'],
                avoidLabelOverlap: false,
                itemStyle: {
                    borderRadius: 10,
                    borderColor: '#fff',
                    borderWidth: 2
                },
                label: {
                    show: false,
                    position: 'center'
                },
                emphasis: {
                    label: {
                        show: true,
                        fontSize: '20',
                        fontWeight: 'bold'
                    }
                },
                labelLine: {
                    show: false
                },
                data: [
                    { value: 35, name: '创业故事' },
                    { value: 28, name: '科技前沿' },
                    { value: 22, name: '文化访谈' },
                    { value: 15, name: '生活分享' }
                ]
            }
        ]
    };
    chart.setOption(option);
}

// 6. 内容状态分布
function initContentStatusChart() {
    const chart = echarts.init(contentStatusChart.value);
    const option = {
        tooltip: {
            trigger: 'item',
            formatter: '{a} <br/>{b}: {c}%'
        },
        legend: {
            data: ['素材导入', '粗剪', '精剪', '发布']
        },
        series: [
            {
                name: '内容转化漏斗',
                type: 'funnel',
                left: '10%',
                top: 60,
                bottom: 60,
                width: '80%',
                min: 0,
                max: 100,
                minSize: '0%',
                maxSize: '100%',
                sort: 'descending',
                gap: 2,
                label: {
                    show: true,
                    position: 'inside'
                },
                labelLine: {
                    length: 10,
                    lineStyle: {
                        width: 1,
                        type: 'solid'
                    }
                },
                itemStyle: {
                    borderColor: '#fff',
                    borderWidth: 1
                },
                emphasis: {
                    label: {
                        fontSize: 20
                    }
                },
                data: [
                    { value: 100, name: '素材导入' },
                    { value: 80, name: '粗剪' },
                    { value: 60, name: '精剪' },
                    { value: 40, name: '发布' }
                ]
            }
        ]
    };
    chart.setOption(option);
}

// 7. 冗余内容剔除率
function initRedundancyRemovalRateChart() {
    const chart = echarts.init(redundancyRemovalRateChart.value);
    const option = {
        series: [
            {
                type: 'gauge',
                center: ['50%', '60%'],
                startAngle: 200,
                endAngle: -20,
                min: 0,
                max: 100,
                itemStyle: {
                    color: '#FF6B9D'
                },
                progress: {
                    show: true,
                    width: 18
                },
                pointer: { show: false },
                axisLine: { lineStyle: { width: 18 } },
                axisTick: { show: false },
                splitLine: { show: false },
                axisLabel: { show: false },
                detail: {
                    valueAnimation: true,
                    fontSize: 28,
                    fontWeight: 'bold',
                    formatter: '{value}%',
                    color: 'inherit'
                },
                data: [{ value: 95.2 }]
            }
        ]
    };
    chart.setOption(option);
}

// 8. 音频修复次数
function initAudioRepairCountChart() {
    const chart = echarts.init(audioRepairCountChart.value);
    const option = {
        xAxis: {
            type: 'category',
            data: ['无痕缝合', '底噪消除', '音量均衡']
        },
        yAxis: { type: 'value' },
        series: [{
            data: [89, 156, 201],
            type: 'bar',
            itemStyle: {
                color: '#C084FC'
            }
        }],
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        tooltip: { trigger: 'axis' }
    };
    chart.setOption(option);
}

// 9. 跨平台分发物料生成数量
function initCrossPlatformMaterialChart() {
    const chart = echarts.init(crossPlatformMaterialChart.value);
    const option = {
        legend: { data: ['视频', '图文'] },
        xAxis: {
            type: 'category',
            data: ['抖音', '小红书', '小宇宙']
        },
        yAxis: { type: 'value' },
        series: [
            {
                name: '视频',
                type: 'bar',
                data: [45, 60, 25],
                itemStyle: { color: '#FF6B9D' }
            },
            {
                name: '图文',
                type: 'bar',
                data: [30, 55, 15],
                itemStyle: { color: '#C084FC' }
            }
        ],
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        tooltip: { trigger: 'axis' }
    };
    chart.setOption(option);
}

// 10. 高频剪辑时段分布
function initEditingTimeDistributionChart() {
    const chart = echarts.init(editingTimeDistributionChart.value);
    const hours = ['12a', '1a', '2a', '3a', '4a', '5a', '6a', '7a', '8a', '9a','10a','11a', '12p', '1p', '2p', '3p', '4p', '5p', '6p', '7p', '8p', '9p', '10p', '11p'];
    const days = ['周日', '周六', '周五', '周四', '周三', '周二', '周一'];
    const data = [[0,0,5],[0,1,1],[0,2,0],[0,3,0],[0,4,0],[0,5,0],[0,6,0],[0,7,0],[0,8,0],[0,9,0],[0,10,0],[0,11,2],[0,12,4],[0,13,1],[0,14,1],[0,15,3],[0,16,4],[0,17,6],[0,18,4],[0,19,4],[0,20,3],[0,21,3],[0,22,2],[0,23,5],[1,0,7],[1,1,0],[1,2,0],[1,3,0],[1,4,0],[1,5,0],[1,6,0],[1,7,0],[1,8,0],[1,9,0],[1,10,5],[1,11,2],[1,12,2],[1,13,6],[1,14,9],[1,15,11],[1,16,6],[1,17,7],[1,18,8],[1,19,12],[1,20,5],[1,21,5],[1,22,7],[1,23,2],[2,0,1],[2,1,1],[2,2,0],[2,3,0],[2,4,0],[2,5,0],[2,6,0],[2,7,0],[2,8,0],[2,9,0],[2,10,3],[2,11,2],[2,12,1],[2,13,9],[2,14,8],[2,15,10],[2,16,6],[2,17,5],[2,18,5],[2,19,6],[2,20,7],[2,21,4],[2,22,2],[2,23,4],[3,0,7],[3,1,3],[3,2,0],[3,3,0],[3,4,0],[3,5,0],[3,6,0],[3,7,0],[3,8,1],[3,9,0],[3,10,5],[3,11,4],[3,12,7],[3,13,14],[3,14,13],[3,15,12],[3,16,9],[3,17,5],[3,18,5],[3,19,10],[3,20,6],[3,21,4],[3,22,4],[3,23,1],[4,0,1],[4,1,3],[4,2,0],[4,3,0],[4,4,0],[4,5,1],[4,6,0],[4,7,0],[4,8,0],[4,9,2],[4,10,4],[4,11,4],[4,12,2],[4,13,4],[4,14,4],[4,15,14],[4,16,12],[4,17,1],[4,18,8],[4,19,5],[4,20,3],[4,21,7],[4,22,3],[4,23,0],[5,0,2],[5,1,1],[5,2,0],[5,3,3],[5,4,0],[5,5,0],[5,6,0],[5,7,0],[5,8,2],[5,9,0],[5,10,4],[5,11,1],[5,12,5],[5,13,10],[5,14,5],[5,15,7],[5,16,11],[5,17,6],[5,18,0],[5,19,5],[5,20,3],[5,21,4],[5,22,2],[5,23,0],[6,0,1],[6,1,0],[6,2,0],[6,3,0],[6,4,0],[6,5,0],[6,6,0],[6,7,0],[6,8,0],[6,9,0],[6,10,1],[6,11,0],[6,12,2],[6,13,1],[6,14,3],[6,15,4],[6,16,0],[6,17,0],[6,18,0],[6,19,0],[6,20,1],[6,21,2],[6,22,2],[6,23,6]]
        .map(function (item) {
        return [item[1], item[0], item[2] || '-'];
    });
    const option = {
        tooltip: { position: 'top' },
        grid: { height: '50%', top: '10%', left: '15%', right: '5%' },
        xAxis: { type: 'category', data: hours, splitArea: { show: true } },
        yAxis: { type: 'category', data: days, splitArea: { show: true } },
        visualMap: {
            min: 0,
            max: 10,
            calculable: true,
            orient: 'horizontal',
            left: 'center',
            bottom: '0%',
            inRange: {
                color: ['#E0F3F8', '#FF6B9D']
            }
        },
        series: [{
            name: '剪辑活动',
            type: 'heatmap',
            data: data,
            label: { show: true },
            emphasis: {
                itemStyle: { shadowBlur: 10, shadowColor: 'rgba(0, 0, 0, 0.5)' }
            }
        }]
    };
    chart.setOption(option);
}

// 11. 常用剪辑功能使用频次
function initCommonFeaturesChart() {
    const chart = echarts.init(commonFeaturesChart.value);
    const option = {
        legend: { data: ['我的使用频次'] },
        radar: {
            indicator: [
                { name: '文本剪辑', max: 100 },
                { name: 'AI粗剪', max: 100 },
                { name: '无痕修复', max: 100 },
                { name: '金句提取', max: 100 },
                { name: '素材检索', max: 100 }
            ]
        },
        series: [{
            name: '常用功能',
            type: 'radar',
            data: [
                { value: [85, 90, 60, 75, 95], name: '我的使用频次' }
            ]
        }]
    };
    chart.setOption(option);
}

// 12. 累计保存的素材片段数量
function initSavedClipsChart() {
    const chart = echarts.init(savedClipsChart.value);
    const option = {
        title: {
            text: '1,288 条',
            left: 'center',
            top: '40%',
            textStyle: { fontSize: 28, fontWeight: 'bold' }
        },
        series: [{
            type: 'pie',
            radius: ['80%', '100%'],
            avoidLabelOverlap: false,
            label: { show: false },
            data: [{ value: 1, itemStyle: { color: '#FF6B9D' } }]
        }]
    };
    chart.setOption(option);
}

</script>

<style scoped>
/* You can add additional styles here if needed */
</style>
