#include "..\Engine\King\Source\Application\Application.h"
#include"..\Engine\King\Source\LuaManager\LuaManager.h"

int main(int argc, char* argv[])
{
    Application App;
    App.Run();
    App.Cleanup();
    return 0;
}