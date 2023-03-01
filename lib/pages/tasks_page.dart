import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:animations/animations.dart';
//import 'package:marquee/marquee.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math'; //show pow;
import 'package:confetti/confetti.dart';

import 'package:todo_app/database/task_helper_db.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/pages/edit_task_page.dart';
import 'package:todo_app/pages/read_task_page.dart';
import 'package:todo_app/pages/tasks_datagrid_page.dart';
import 'package:todo_app/pages/tasks_datagrid_sf_page.dart';

import 'package:lottie/lottie.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:animated_background/animated_background.dart';

const Color primary = Colors.white;
final Color active = Colors.grey.shade800;
final Color divider = Colors.grey.shade400;

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  List<Task> tasks = [];
  bool isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future loadTasks() async {
    setState(() => isLoading = true);
    tasks = await TaskHelper.instance.readAllTasks();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final listKey = GlobalObjectKey<ListViewState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Developer');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
            onPressed: () => showDialog<void>(
                context: context, builder: (_) => _showDialog(listKey, tasks)),
            tooltip: '親 → 孫',
          ),
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TasksGridviewPage(
                      tasks: tasks, callback: () => loadTasks())));
            },
            tooltip: 'DataGrid',
          ),
          IconButton(
            icon: const Icon(Icons.grid_on, color: Colors.orange),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TasksGridviewSfPage(
                      tasks: tasks, callback: () => loadTasks())));
            },
            tooltip: 'DataGrid Syncfusion',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      drawerEdgeDragWidth: 0, //←エッジスワイプを不可に
      body: isLoading
          ? const Center(
              /*
              child: SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.orange))
              */
              /*
              child: Lottie.asset(
                'assets/106483-download.json',
                width: 250,
                height: 250,
                repeat: true,
                reverse: false,
                animate: true,
              ),
              */
              child: LoadingCustomAnimation(),
            )
          : //LogoAnimatedBackground(child:
          Scrollbar(
              thumbVisibility: true,
              thickness: 8,
              //hoverThickness: 16,
              radius: const Radius.circular(16),
              child: SizedBox(
                  child: RefreshIndicator(
                      onRefresh: () async => loadTasks(),
                      child: ListViewBuild(
                        key: listKey,
                        tasks: tasks,
                        callback: () => loadTasks(),
                      )))),
      //),
      /*
            Scrollbar(
              thumbVisibility: true,
              thickness: 8,
              //hoverThickness: 16,
              radius: const Radius.circular(16),
              child: SizedBox(
                child: RefreshIndicator(
                  onRefresh: () async => loadTasks(),
                  child: ListViewBuild(
                    key: listKey,
                    tasks: tasks,
                    callback: () => loadTasks(),
                  )))),
            */

      /*
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 600),
        openBuilder: (context, _) => const EditTaskPage(),
        onClosed: (_) => loadTasks(),
        closedElevation: 8,
        openElevation: 8,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(28),
          ),
        ),
        closedColor: Colors.indigo,
        closedBuilder: (context, openContainer) => Container(
          color: Colors.indigo,
          height: 56,
          width: 56,
          child: const Center(
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
      */
      floatingActionButton: FloatingActionButton(
        child: Container(
          child: const Icon(
            Icons.add_task,
          ),
          height: 56,
          width: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent,
                Colors.redAccent,
              ],
            ),
          ),
        ),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EditTaskPage()),
          );
          loadTasks();
        },
        tooltip: '追加',
      ),
    );
  }

  Widget _buildDrawer() {
    final controller =
        ConfettiController(duration: const Duration(milliseconds: 200));
    return ClipPath(
        clipper: OvalRightBorderClipper(),
        child: Drawer(
          child: Stack(children: [
            const Positioned(
                child: SizedBox(
              child: CircularParticleScreen(),
            )),
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 40,
              ),
              width: 300,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              const Icon(Icons.favorite,
                                  color: Colors.pink, size: 12),
                              Icon(Icons.hiking, color: active),
                              const Icon(Icons.terrain, color: Colors.green),
                            ],
                          ),
                          /* Draggable(
                  //data: 'Green',
                  child: logo(),
                  feedback: logo(),
                  childWhenDragging: const SizedBox(
                    width: 95,
                    height: 95)), */
                          //  const DraggableLogo(),//
                          /* Container(
                  height: 95,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.greenAccent.shade400, width: 5.0),
                      shape: BoxShape.circle,
                      color: primary),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(image))), */
                          /* Container(
                  height: 95,
                  width: 95,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red,
                        Colors.yellow,
                      ])),
                  child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    padding: const EdgeInsets.all(2.0),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(image),
                    ))), */
                          Container(
                            height: 120.0,
                            color: Colors.transparent,
                          ),
                          const Text(
                            "FUKUJU IoT",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "dev@AtsushiTanase",
                            style: TextStyle(color: active, fontSize: 16.0),
                          ),
                          const SizedBox(height: 40.0),
                          _buildRow(
                            icon: Icons.factory,
                            title: "Company profile",
                            comment:
                                "福寿工業株式会社\n岐阜県羽島市小熊町西小熊4005\nTel (058)392-2111\nFax (058)392-8723\nhttp://www.fukujukk.co.jp",
                            qr: true,
                            qrData: "http://www.fukujukk.co.jp",
                          ),
                          _buildRow(
                            icon: Icons.person,
                            title: "My profile",
                            comment: "棚瀬敦史\nトランスミッショングループ 製造",
                          ),
                          _buildRow(
                            icon: Icons.email,
                            title: "Contact us",
                            comment: "a_tanase@fukujukk.co.jp",
                            qr: true,
                            qrData: "a_tanase@fukujukk.co.jp",
                          ),
                          _buildRow(
                            icon: Icons.groups,
                            title: "About us",
                            comment: "FUKUJU IoT\nなにか役に立つモノが\n作れればと思ってます…",
                          ),
                        ],
                      ),
                      Positioned(
                        top: 40 + 95 / 2 - 10,
                        left: 248 / 2 - 10,
                        child: ConfettiWidget(
                          confettiController: controller,
                          //displayTarget: true,
                          numberOfParticles: 5,
                          blastDirectionality: BlastDirectionality.explosive,
                          colors: const [
                            Colors.yellowAccent,
                            Colors.blueAccent,
                            Colors.greenAccent
                          ],
                          createParticlePath: _drawStar,
                          maximumSize: const Size(40, 40),
                          minimumSize: const Size(10, 10),
                          maxBlastForce: 3,
                          minBlastForce: 2,
                          emissionFrequency: 0.5,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 248 / 2 - 95 / 2,
                        child: DraggableLogo(controller: controller),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
  }

  Path _drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    required String comment,
    bool qr = false,
    String? qrData,
  }) {
    final TextStyle textStyle = TextStyle(color: active, fontSize: 16.0);
    double qrSize = 100.0;
    double embeddedImageSize = qrSize * 0.2;
    return Column(
      children: <Widget>[
        ExpansionTile(
          //onExpansionChanged: (bool changed) {}, //←タップしたときの動作はココ
          leading: Icon(icon),
          title: Text(
            title,
            style: textStyle,
          ),
          children: [
            Text(comment),
            (qr)
                ? QrImage(
                    padding: const EdgeInsets.all(5),
                    data: qrData!,
                    version: QrVersions.auto,
                    size: qrSize,
                    embeddedImage: const AssetImage('assets/logo3.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(embeddedImageSize, embeddedImageSize)),
                    constrainErrorBounds: true,
                    embeddedImageEmitsError: true,
                  )
                : const SizedBox(),
            const SizedBox(height: 5),
          ],
          //subtitle: Text('subtitle'),
        ),
        Divider(thickness: 1, height: 0, color: divider),
      ],
    );
  }

  Widget _showDialog(GlobalObjectKey<ListViewState> listKey, List<Task> tasks) {
    List<Widget> items = [];
    for (int i = 0; i < tasks.length; i++) {
      items.add(
        SimpleDialogOption(
          onPressed: () => listKey.currentState?.animate(i),
          child: Text(
            'index: $i  id: ${tasks[i].id} name: ${tasks[i].name}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return SimpleDialog(
      title: const Text('親Widget → 孫Widget'),
      children: items,
    );
  }
}

class OvalRightBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width - 40, 0);
    path.quadraticBezierTo(
        size.width, size.height / 4, size.width, size.height / 2);
    path.quadraticBezierTo(size.width, size.height - (size.height / 4),
        size.width - 40, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class DraggableLogo extends StatefulWidget {
  const DraggableLogo({Key? key, required this.controller}) : super(key: key);
  final ConfettiController controller;

  @override
  DraggableLogoState createState() => DraggableLogoState();
}

class DraggableLogoState extends State<DraggableLogo> {
  static const _baseSize = 95.0;
  static const _targetSize = 95.0;
  static const _defaultDelta = (_baseSize - _targetSize) / 2;

  var _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          alignment: Alignment.center,
          width: _baseSize,
          height: _baseSize,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red, Colors.yellow])),
          child: Container(
              width: 85,
              height: 85,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white)),
        ),
        AnimatedPositioned(
          left: _defaultDelta + _offset.dx,
          top: _defaultDelta + _offset.dy,
          duration: Duration(milliseconds: _offset == Offset.zero ? 800 : 0),
          curve: Curves.elasticOut,
          child: GestureDetector(
              onPanUpdate: (update) => setState(() => _offset += update.delta),
              onPanEnd: (info) {
                if (pow(_offset.dx, 2) + pow(_offset.dy, 2) <=
                    pow(_baseSize / 2, 2)) {
                  return;
                }
                setState(() {
                  _offset = Offset.zero;
                  widget.controller.play();
                });
              },
              child: logo()),
        ),
      ],
    );
  }

  Widget logo() {
    const String image = 'assets/logo.png';
    const double logoSize = 95.0;
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, color: Colors.transparent),
      padding: const EdgeInsets.all(6.0),
      child: const CircleAvatar(
        //radius: 42.5,
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage(image),
      ),
    );
  }
}

class ListViewBuild extends StatefulWidget {
  const ListViewBuild({super.key, required this.tasks, required this.callback});

  final List<Task> tasks;
  final Function callback;

  @override
  State<StatefulWidget> createState() => ListViewState();
}

class ListViewState extends State<ListViewBuild> {
  final List<GlobalObjectKey<ListViewItemState>> keys = [];

  final today = DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now()));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    for (var task in widget.tasks) {
      keys.add(GlobalObjectKey(task));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.all(5),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          /*
                      child: OpenContainer(
                        transitionDuration: const Duration(milliseconds: 600),
                        openBuilder: (context, _) =>
                            ReadTaskPage(taskId: task.id!),
                        onClosed: (_) => loadTasks(),
                        closedShape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        closedColor: Colors.white,
                        closedBuilder: (context, openContainer) => InkWell(
                          borderRadius: BorderRadius.circular(15),
                        */
          child: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value:
                          (widget.tasks[index].completed == 1) ? true : false,
                      onChanged: (bool? value) {
                        setState(() => widget.tasks[index].completed =
                            (value == true) ? 1 : 0);
                        TaskHelper.instance.updateTask(widget.tasks[index]);
                      },
                    ),
                  ),
                  */
                  /*
                  Builder(
                    builder: (context) => ListViewItem(
                      key: keys[index],
                      task: widget.tasks[index],
                      callback: () => setState(() {}),
                    ),
                  ),
                  */
                  ListViewItem(
                    key: keys[index],
                    task: widget.tasks[index],
                    callback: () => setState(() {}),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: _text(
                              text: '${widget.tasks[index].priority}',
                              fontColor: Colors.white,
                              bold: true,
                              fontSize: 14,
                            ),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _selectPriorityColor(
                                  priority: widget.tasks[index].priority),
                              shape: BoxShape.circle,
                              //border: Border.all(color: Colors.black54, width: 1.5),
                              /* boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey, //色
                                      //spreadRadius: 5,
                                      blurRadius: 8,
                                      offset: Offset(2, 2),
                                    ),
                                  ],*/
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            //width: 250.0,
                            width: MediaQuery.of(context).size.width - 130,
                            child: _text(
                              text: widget.tasks[index].name,
                              bold: true,
                              fontSize: 24,
                              completed: (widget.tasks[index].completed == 1)
                                  ? true
                                  : false,
                              //shadow: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _text(text: '期限：'),
                          _text(
                            text:
                                DateFormat('yyyy/MM/dd E   ') //yyyy/MM/dd HH:mm
                                    .format(widget.tasks[index].deadline),
                          ),
                          widget.tasks[index].deadline.isAfter(
                            today.add(const Duration(days: -1)),
                          )
                              ? _text(
                                  text:
                                      'あと${widget.tasks[index].deadline.difference(today).inDays}日',
                                  fontColor: Colors.indigo,
                                  bold: true,
                                )
                              : _text(
                                  text: '期限切れ',
                                  bold: true,
                                  fontColor: Colors.red,
                                  shadow: true,
                                  shadowColor: Colors.lime,
                                ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ReadTaskPage(taskId: widget.tasks[index].id!),
                ),
              );
              widget.callback();
            },
          ),
        );
      },
    );
  }

  Color _selectPriorityColor({required int priority}) {
    Color color;
    switch (priority) {
      case 1:
        color = Colors.blue;
        break;
      case 2:
        color = Colors.green;
        break;
      case 3:
        color = Colors.orange;
        break;
      case 4:
        color = Colors.red;
        break;
      case 5:
        color = Colors.purple;
        break;
      default:
        color = Colors.white;
        break;
    }
    return color;
  }

  Text _text({
    required String text,
    bool bold = false,
    double fontSize = 15,
    Color fontColor = Colors.black,
    bool completed = false,
    bool shadow = false,
    Color shadowColor = Colors.grey,
  }) {
    return Text(text,
        style: TextStyle(
          fontSize: fontSize,
          color: completed ? Colors.black54 : fontColor,
          fontWeight: bold ? FontWeight.bold : null,
          decoration: completed ? TextDecoration.lineThrough : null,
          decorationColor: Colors.red.withOpacity(0.5),
          decorationThickness: 3.0,
          shadows: shadow
              ? [
                  Shadow(
                    offset: const Offset(1.0, 1.0),
                    blurRadius: 8.0,
                    color: shadowColor,
                  )
                ]
              : null,
        ),
        overflow: TextOverflow.ellipsis);
  }

  void animate(int index) {
    keys[index].currentState?.animate();
  }
}

class ListViewItem extends StatefulWidget {
  const ListViewItem({super.key, required this.task, required this.callback});

  final Task task;
  final Function callback;

  @override
  State<StatefulWidget> createState() => ListViewItemState();
}

class ListViewItemState extends State<ListViewItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        lowerBound: 0.15,
        upperBound: 0.4,
        duration: const Duration(milliseconds: 800),
        reverseDuration: const Duration(milliseconds: 800))
      ..value = (widget.task.completed == 0) ? 0.15 : 0.4;
    //..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => animate(),
      child: SizedBox(
        height: 60,
        width: 60,
        child: OverflowBox(
          maxHeight: 100,
          minHeight: 100,
          maxWidth: 100,
          minWidth: 100,
          child: Lottie.asset(
            'assets/75338-check-animation.json',
            width: 60,
            height: 60,
            repeat: false,
            controller: _animationController,
          ),
        ),
      ),
    );
  }

  Future animate() async {
    if (widget.task.completed == 0) {
      //_animationController.reset();
      //_animationController.value = 0.15;
      _animationController.forward();
      widget.task.completed = 1;
    } else {
      //_animationController.value = 0.4;
      _animationController.reverse();
      widget.task.completed = 0;
    }
    TaskHelper.instance.updateTask(widget.task);
    widget.callback();
  }
}

class LoadingCustomAnimation extends StatefulWidget {
  const LoadingCustomAnimation({Key? key}) : super(key: key);

  @override
  _LoadingCustomAnimationState createState() => _LoadingCustomAnimationState();
}

class _LoadingCustomAnimationState extends State<LoadingCustomAnimation>
    with TickerProviderStateMixin {
  late AnimationController controller1,
      controller2,
      controller3,
      controller4,
      controller5;
  late Animation<double> animation1,
      animation2,
      animation3,
      animation4,
      animation5;

  @override
  void initState() {
    super.initState();

    controller1 = _animationController(milliseconds: 6000);
    controller2 = _animationController(milliseconds: 3000);
    controller3 = _animationController(milliseconds: 2000);
    controller4 = _animationController(milliseconds: 1500);
    controller5 = _animationController(milliseconds: 1000);

    animation1 = _animation(animationController: controller1);
    animation2 = _animation(animationController: controller2);
    animation3 = _animation(animationController: controller3);
    animation4 = _animation(animationController: controller4);
    animation5 = _animation(animationController: controller5);

    controller1.forward();
    controller2.forward();
    controller3.forward();
    controller4.forward();
    controller5.forward();
  }

  AnimationController _animationController({required milliseconds}) {
    return AnimationController(
        vsync: this, duration: Duration(milliseconds: milliseconds));
  }

  Animation<double> _animation({required animationController}) {
    return Tween<double>(begin: -pi, end: pi).animate(animationController)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100,
        width: 100,
        child: CustomPaint(
            painter: MyPainter(
          animation1.value,
          animation2.value,
          animation3.value,
          animation4.value,
          animation5.value,
        )));
  }
}

class MyPainter extends CustomPainter {
  final double startAngle1;
  final double startAngle2;
  final double startAngle3;
  final double startAngle4;
  final double startAngle5;

  MyPainter(this.startAngle1, this.startAngle2, this.startAngle3,
      this.startAngle4, this.startAngle5);

  @override
  void paint(Canvas canvas, Size size) {
    Paint myArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromLTRB(0, 0, size.width, size.height), startAngle1, 2,
        false, myArc..color = (Colors.blue));
    canvas.drawArc(
        Rect.fromLTRB(size.width * .1, size.height * .1, size.width * .9,
            size.height * .9),
        startAngle2,
        2,
        false,
        myArc..color = (Colors.green));
    canvas.drawArc(
        Rect.fromLTRB(size.width * .2, size.height * .2, size.width * .8,
            size.height * .8),
        startAngle3,
        2,
        false,
        myArc..color = (Colors.orange));
    canvas.drawArc(
        Rect.fromLTRB(size.width * .3, size.height * .3, size.width * .7,
            size.height * .7),
        startAngle4,
        2,
        false,
        myArc..color = (Colors.red));

    canvas.drawArc(
        Rect.fromLTRB(size.width * .4, size.height * .4, size.width * .6,
            size.height * .6),
        startAngle5,
        2,
        false,
        myArc..color = (Colors.purple));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircularParticleScreen extends StatelessWidget {
  const CircularParticleScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height + 100;
    double screenWidth = MediaQuery.of(context).size.width + 100;
    return CircularParticle(
      key: UniqueKey(),
      awayRadius: 80,
      numberOfParticles: 200,
      speedOfParticles: 1,
      height: screenHeight,
      width: screenWidth,
      onTapAnimation: true,
      particleColor: Colors.grey.withAlpha(20),
      awayAnimationDuration: const Duration(milliseconds: 600),
      maxParticleSize: 7,
      isRandSize: true,
      isRandomColor: false,
      awayAnimationCurve: Curves.easeInOutBack,
      enableHover: true,
      hoverColor: Colors.red.withAlpha(50),
      hoverRadius: 80,
      connectDots: true, //not recommended
    );
  }
}

class LogoAnimatedBackground extends StatefulWidget {
  const LogoAnimatedBackground({Key? key, required this.child})
      : super(key: key);
  final Widget child;
  @override
  _LogoAnimatedBackgroundState createState() => _LogoAnimatedBackgroundState();
}

class _LogoAnimatedBackgroundState extends State<LogoAnimatedBackground>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      behaviour: RandomParticleBehaviour(
        options: ParticleOptions(
          image: Image.asset("assets/logo.png"),
          baseColor: Colors.blue,
          spawnOpacity: 0.0,
          opacityChangeRate: 0.25,
          minOpacity: 0.0,
          maxOpacity: 0.1,
          spawnMinSpeed: 60.0,
          spawnMaxSpeed: 90.0,
          spawnMinRadius: 15.0,
          spawnMaxRadius: 30.0,
          particleCount: 25,
        ),
      ),
      vsync: this,
      child: widget.child,
    );
  }
}
