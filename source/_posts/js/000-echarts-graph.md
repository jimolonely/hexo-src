---
title: echarts中的graph demo
tags:
  - javascript
  - html
  - web
p: js/000-echarts-graph
date: 2018-03-13 08:38:44
---
关于echart-graph,一个乔布斯关系图demo.

# 上代码
```javascript
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <!-- 引入 ECharts 文件 -->
    <script src="echarts.js"></script>
</head>

<body>

    <!-- 为 ECharts 准备一个具备大小（宽高）的 DOM -->
    <div id="main" style="width: 1000px;height:600px;"></div>
    <script type="text/javascript">
        // 基于准备好的dom，初始化echarts实例
        var myChart = echarts.init(document.getElementById('main'));

        option1 = {
            title: {
                text: '人物关系：乔布斯',
                subtext: '数据来自人立方',
                top: 'top',
                left: 'middle'
            },
            animationDuration: 1500,
            animationEasingUpdate: 'quinticInOut',
            tooltip: {
                trigger: 'item',
                formatter: '{a} : {b}'
            },
            toolbox: {
                show: true,
                feature: {
                    restore: { show: true },
                    magicType: { show: true, type: ['force', 'chord'] },
                    saveAsImage: { show: true }
                }
            },
            legend: {
                x: 'left',
                data: ['家人', '朋友']
            },
            series: [
                {
                    type: 'graph',
                    name: "人物关系",
                    layout: 'force',
                    categories: [
                        {
                            name: '人物'
                        },
                        {
                            name: '家人'
                        },
                        {
                            name: '朋友'
                        }
                    ],
                    label: {
                        show: true,
                        position: 'inside',
                    },
                    lineStyle: {
                        normal: {
                            color: 'source',
                            curveness: 0.3
                        }
                    }
                    ,
                    // minRadius: 15,
                    // maxRadius: 25,
                    roam: true,
                    nodes: [
                        {
                            category: 0,
                            name: '乔布斯',
                            value: 10,
                            symbolSize: 50,//[60, 35],
                            draggable: true,
                        },
                        { category: 1, name: '丽萨-乔布斯', value: 2 },
                        { category: 1, name: '保罗-乔布斯', value: 3 },
                        { category: 1, name: '克拉拉-乔布斯', value: 3 },
                        { category: 1, name: '劳伦-鲍威尔', value: 7 },
                        { category: 2, name: '史蒂夫-沃兹尼艾克', value: 5 },
                        { category: 2, name: '奥巴马', value: 8 },
                        { category: 2, name: '比尔-盖茨', value: 9 },
                        { category: 2, name: '乔纳森-艾夫', value: 4 },
                        { category: 2, name: '蒂姆-库克', value: 4 },
                        { category: 2, name: '龙-韦恩', value: 1 },
                    ],
                    links: [
                        {
                            source: '丽萨-乔布斯', target: '乔布斯', name: '女儿'
                        },
                        {
                            source: '乔布斯', target: '丽萨-乔布斯', name: '父亲', itemStyle: {
                                normal: { color: 'red' }
                            }
                        },
                        { source: '保罗-乔布斯', target: '乔布斯', name: '父亲' },
                        { source: '克拉拉-乔布斯', target: '乔布斯', name: '母亲' },
                        { source: '劳伦-鲍威尔', target: '乔布斯', },
                        { source: '史蒂夫-沃兹尼艾克', target: '乔布斯', name: '合伙人' },
                        { source: '奥巴马', target: '乔布斯', },
                        { source: '比尔-盖茨', target: '乔布斯', name: '竞争对手' },
                        { source: '乔纳森-艾夫', target: '乔布斯', name: '爱将' },
                        { source: '蒂姆-库克', target: '乔布斯', },
                        { source: '龙-韦恩', target: '乔布斯', },
                        { source: '龙-韦恩', target: '乔纳森-艾夫', },
                        { source: '克拉拉-乔布斯', target: '保罗-乔布斯', },
                        { source: '奥巴马', target: '保罗-乔布斯', },
                        { source: '奥巴马', target: '克拉拉-乔布斯', },
                        { source: '奥巴马', target: '劳伦-鲍威尔', },
                        { source: '奥巴马', target: '史蒂夫-沃兹尼艾克', },
                        { source: '比尔-盖茨', target: '奥巴马', },
                        { source: '比尔-盖茨', target: '克拉拉-乔布斯', },
                        { source: '蒂姆-库克', target: '奥巴马', }
                    ]
                }
            ]
        };

        // 使用刚指定的配置项和数据显示图表。
        myChart.setOption(option1);
    </script>
</body>

</html>
```
效果:

{% asset_img 000.png demo-graph %}