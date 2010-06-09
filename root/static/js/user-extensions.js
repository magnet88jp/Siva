/**
 * storeValue, storeText, storeAttribute and store actions now
 * have 'global' equivalents.
 * Use storeValueGlobal, storeTextGlobal, storeAttributeGlobal or storeGlobal
 * will store the variable globally, making it available it subsequent tests.
 *
 * See the Reference.html for storeValue, storeText, storeAttribute and store
 * for the arguments you should send to the new Global functions.
 *
 * example of use
 * in testA.html:
 * +------------------+----------------------+----------------------+
 * |storeGlobal       | http://localhost/    | baseURL              |
 * +------------------+----------------------+----------------------+
 *
 * in textB.html (executed after testA.html):
 * +------------------+-----------------------+--+
 * |open              | ${baseURL}Main.jsp    |  |
 * +------------------+-----------------------+--+
 *
 * Note: Selenium.prototype.replaceVariables from selenium-api.js has been replaced
 *       here to make it use global variables if no local variable is found.
 *       This might cause issues if you upgraded Selenium in the future and this function
 *       has been changed.
 *
 * @author Guillaume Boudreau
 */
 
globalStoredVars = new Object();

/*
 * Globally store the value of a form input in a variable
 */
Selenium.prototype.doStoreValueGlobal = function(target, varName) {
    if (!varName) {
        // Backward compatibility mode: read the ENTIRE text of the page
        // and stores it in a variable with the name of the target
        value = this.page().bodyText();
        globalStoredVars[target] = value;
        return;
    }
    var element = this.page().findElement(target);
    globalStoredVars[varName] = getInputValue(element);
};

/*
 * Globally store the text of an element in a variable
 */
Selenium.prototype.doStoreTextGlobal = function(target, varName) {
    var element = this.page().findElement(target);
    globalStoredVars[varName] = getText(element);
};

/*
 * Globally store the value of an element attribute in a variable
 */
Selenium.prototype.doStoreAttributeGlobal = function(target, varName) {
    globalStoredVars[varName] = this.page().findAttribute(target);
};

/*
 * Globally store the result of a literal value
 */
Selenium.prototype.doStoreGlobal = function(value, varName) {
    globalStoredVars[varName] = value;
};

/*
 * Search through str and replace all variable references ${varName} with their
 * value in storedVars (or globalStoredVars).
 */
Selenium.prototype.replaceVariables = function(str) {
    var stringResult = str;

    // add by nishino
    var matchDot = stringResult.match(/\$\{\w+\.\w+\}/g);
    if(matchDot) {
      stringResult = str.replace(/(\$\{\w+)\.(\w+\})/g, "$1___CLASS___$2");
    }

    // Find all of the matching variable references
    var match = stringResult.match(/\$\{\w+\}/g);
    if (!match) {
        return stringResult;
    }

    // For each match, lookup the variable value, and replace if found
    for (var i = 0; match && i < match.length; i++) {
        var variable = match[i]; // The replacement variable, with ${}
        var name = variable.substring(2, variable.length - 1); // The replacement variable without ${}
        var replacement = storedVars[name];
        if (replacement != undefined) {
            stringResult = stringResult.replace(variable, replacement);
        }
        var replacement = globalStoredVars[name];
        if (replacement != undefined) {
            stringResult = stringResult.replace(variable, replacement);
        }
    }
    return stringResult;
};

/*
 * ��������ǉ�
 */
globalInstanceClassMap = new Object();
globalClassVariableList = new Array();
globalInstanceCounter = new Object();
/*
 * �ϐ��̒�`
 * setVariable("i", "h"); �ŁAh�N���X�̃C���X�^���Xi�𐶐�����B
 */
Selenium.prototype.doSetVariable = function(instanceName, className) {
  globalInstanceClassMap[instanceName] = className;
  globalInstanceCounter[className] = 0;
};

Selenium.prototype.doSetSuiteValue = function(target, value) {
    var ns = Selenium.prototype;
   
    // �����Avalue�� ___CLASS___ ���܂܂�Ă�����A___INSTA___ �֕ϊ�
    var stringValue = value.replace("___CLASS___", "___INSTA___");

    // target����A�C���X�^���X�����擾(.�h�b�g�ŋ�؂��Ă���j
    var stringTarget = target;
    var match = stringTarget.match(/(\w+)\.(\w+)/);
    if (match) {
      var stringInstance = RegExp.$1;
      var stringVariable = RegExp.$2;
     
      // �C���X�^���X�������ӂ̕ϐ����쐬
      stringTarget = stringInstance + "___INSTA___" + stringVariable;
    }
    // storeGlobal�֑}��
    ns.doStoreGlobal(stringValue, stringTarget);
   
};



Selenium.prototype.doSetCaseValue = function(target, value) {
    var ns = Selenium.prototype;
   
    // target����A�N���X�����擾(.�h�b�g�ŋ�؂��Ă���j
    var stringTarget = target;
    var match = stringTarget.match(/(\w+)\.(\w+)/);
   
    if (match) {
      var stringInstance = RegExp.$1;
      var stringVariable = RegExp.$2;
      stringTarget = stringInstance + "___CLASS___" + stringVariable;
    }
   
    // �C���X�^���X�������ӂ̕ϐ����쐬
    // storeGlobal�֑}��
    ns.doStoreGlobal(value, stringTarget);
   
    // globalClassVariableList �֑}��
    globalClassVariableList.push(stringTarget);
   
};

Selenium.prototype.doBindValue = function(className) {
  var ns = Selenium.prototype;

  // �N���X���̕ϐ���bind����
  var cnt = 0;
  for(var name in globalInstanceClassMap) {
    if(globalInstanceClassMap[name] == className) {
      // cnt ���r�����̂��C���N�������g
      if(globalInstanceCounter[className] == cnt++) {
        // globalClassVariableList �����(pop)
        var classVar;
        while(classVar = globalClassVariableList.pop()) {
          var stringTarget = classVar;
          // �f���~�^ ___CLASS___ �ŕ���
          var match = stringTarget.match(/(\w+)___CLASS___(\w+)/);
          var stringClass = RegExp.$1;
          var stringVariable = RegExp.$2;
          // �C���X�^���X��.�N���X�ϐ��ɊY������ϐ������쐬
          var stringInstance = name + "___INSTA___" + stringVariable;
          if(globalStoredVars[stringInstance]) {
            // gs[j____INSTA___linkcommand] �̒l���`�F�b�N���A${xxx}�ň͂܂�Ă�����Ags���猟�����āA�l���đ������
            var replaceString = ns.replaceVariables(globalStoredVars[stringInstance]);
            globalStoredVars[stringTarget] = replaceString;
          }
        }
        globalInstanceCounter[className] = cnt;
        break;
      }
    }
  }
};

