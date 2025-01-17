import 'package:inspector/infospect/features/network/models/infospect_network_call.dart';
import 'package:inspector/infospect/features/network/ui/details/models/details_topic_data.dart';
import 'package:inspector/infospect/utils/extensions/infospect_network/network_request_extension.dart';
import 'package:inspector/infospect/utils/extensions/int_extension.dart';

class RequestDetailsTopicHelper {
  RequestDetailsTopicHelper(this.call) {
    initTopics();
  }

  final InfospectNetworkCall call;

  late TopicData _generalTopics;
  late TopicData _summaryTopics;
  TopicData? _headerTopics;
  TopicData? _queryTopics;
  TopicData? _formDataFieldsTopics;
  TopicData? _formDataFilesTopics;
  TopicData? _bodyTopics;

  void initTopics() {
    _setupGeneralTopics();
    _setupSummaryTopics();

    if (call.request?.headers.isNotEmpty ?? false) {
      _setupHeaderTopics();
    }

    if (call.request?.queryParameters.isNotEmpty ?? false) {
      _setupQueryTopics();
    }

    if (call.request?.formDataFields?.isNotEmpty ?? false) {
      _setupFormDataFieldsTopics();
    }

    if (call.request?.formDataFiles?.isNotEmpty ?? false) {
      _setupFormDataTopics();
    }

    if (call.request?.body != null &&
        (call.request?.bodyMap ?? {}).isNotEmpty) {
      _setupBodyTopics();
    }
  }

  List<TopicData> get topics {
    final List<TopicData> list = [];
    list.add(_generalTopics);
    if (_headerTopics != null) list.add(_headerTopics!);
    if (_queryTopics != null) list.add(_queryTopics!);
    if (_formDataFieldsTopics != null) list.add(_formDataFieldsTopics!);
    if (_formDataFilesTopics != null) list.add(_formDataFilesTopics!);
    if (_bodyTopics != null) list.add(_bodyTopics!);
    list.add(_summaryTopics);

    return list;
  }

  List<TopicData> get desktopTopics {
    final List<TopicData> list = [];
    if (_headerTopics != null) list.add(_headerTopics!);
    if (_queryTopics != null) list.add(_queryTopics!);
    if (_formDataFieldsTopics != null) list.add(_formDataFieldsTopics!);
    if (_formDataFilesTopics != null) list.add(_formDataFilesTopics!);
    if (_bodyTopics != null) list.add(_bodyTopics!);
    list.add(_generalTopics);
    list.add(_summaryTopics);

    return list;
  }

  /// general topic data setup
  void _setupGeneralTopics() {
    _generalTopics = (
      topic: 'General',
      body: TopicDetailsBodyList(
        [
          (
            title: 'Url:',
            subtitle: 'Server: ${call.server}',
            other: 'Endpoint: ${call.endpoint}',
          ),
          (
            title: 'Time:',
            subtitle: 'Start : ${call.request!.time}',
            other: call.response != null
                ? 'Finish : ${call.response!.time.toString()}'
                : '',
          ),
          (title: 'Method: ', subtitle: call.method, other: null),
          (
            title: 'Duration:',
            subtitle: call.duration.toReadableTime,
            other: null,
          ),
        ],
      )
    );
  }

  /// summary related topic data setup
  void _setupSummaryTopics() {
    _summaryTopics = (
      topic: 'Summary',
      body: TopicDetailsBodyList(
        [
          (
            title: 'Data transmitted:',
            subtitle: 'Sent: ${call.request!.size.toReadableBytes}',
            other: call.response != null
                ? 'Received: ${call.response!.size.toReadableBytes}'
                : '',
          ),
          (
            title: "Client:",
            subtitle: call.client,
            other: null,
          ),
        ],
      )
    );
  }

  /// header related topic data setup
  void _setupHeaderTopics() {
    _headerTopics = (
      topic: 'Headers',
      body: TopicDetailsBodyMap(
        map: call.request?.headers ?? {},
        trailing: (
          trailing: 'View raw',
          data: call.request?.headers ?? {},
          beautificationRequired: false,
        ),
      )
    );
  }

  void _setupQueryTopics() {
    _queryTopics = (
      topic: 'Query',
      body: TopicDetailsBodyMap(
        map: call.request?.queryParameters ?? {},
        trailing: (
          trailing: 'View raw',
          data: call.request?.queryParameters ?? {},
          beautificationRequired: false,
        ),
      )
    );
  }

  /// form data fields related topic data setup
  void _setupFormDataFieldsTopics() {
    _formDataFieldsTopics = (
      topic: 'Form Data Fields',
      body: TopicDetailsBodyMap(
        map: {for (var e in call.request!.formDataFields!) e.name: e.value},
      )
    );
  }

  /// form data files related topic data setup
  void _setupFormDataTopics() {
    _formDataFilesTopics = (
      topic: 'Form Data Files',
      body: TopicDetailsBodyMap(
        map: {
          for (var e in call.request!.formDataFiles!)
            e.fileName ?? '': '${e.contentType} / ${e.length} B'
        },
      )
    );
  }

  /// body related topic data setup
  void _setupBodyTopics() {
    _bodyTopics = (
      topic: 'Body',
      body: TopicDetailsBodyMap(
        map: {'': call.request?.body?.toString() ?? ''},
        trailing: (
          trailing: 'View Body',
          data: call.request?.bodyMap ?? {},
          beautificationRequired: false,
        ),
      )
    );
  }
}
