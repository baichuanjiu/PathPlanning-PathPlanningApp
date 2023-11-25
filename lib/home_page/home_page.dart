import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "首页",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text("欢迎使用！", style: Theme.of(context).textTheme.headlineLarge),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                "\t\t\t\t\t\t\t\t我们团队使用经过预训练和改进的D-LinkNet模型进行道路提取工作。在经过29个小时，184轮训练后（数据集大小：6226张），模型的loss下降至0.21并且在测试集表现良好。",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                "\t\t\t\t\t\t\t\t随后，在上一步的基础上，我们使用训练好的模型进一步进行迁移学习，通过在Google Earth上获取的400张数据（涉及农田类型：丘陵梯田、平原田垄）完成了此项工作。",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                "\t\t\t\t\t\t\t\t现在，我们已经将推理模型部署至服务器上，你可以使用此APP，通过上传一张1024 * 1024分辨率的图像来体验D-LinkNet模型在道路提取上的惊人准确率。",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                "\t\t\t\t\t\t\t\t当你使用我们的程序完成道路提取后，可以进一步点击“路径规划”按钮，我们还提供了使用A星算法完成的路径规划功能。",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/pathExtraction');
                  },
                  child: const Text("开始"),
                ),
              ),
            ),
          ],
        ),),
      ),
    );
  }
}
