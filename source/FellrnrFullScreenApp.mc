using Toybox.Application;

class FellrnrFullScreenApp extends Application.AppBase {

    private var _view;

    function initialize() {
        AppBase.initialize();
        _view = new FellrnrFullScreenView();
    }

    // onStart() is called on application start up
    function onStart(state) {
        _view.onStart();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        _view.onStop();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ _view ];
    }

}