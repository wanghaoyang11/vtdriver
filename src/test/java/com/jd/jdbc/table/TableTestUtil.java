/*
Copyright 2021 JD Project Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package com.jd.jdbc.table;

import com.jd.jdbc.Executor;
import com.jd.jdbc.tindexes.LogicTable;
import com.jd.jdbc.tindexes.config.SplitTableConfig;
import com.jd.jdbc.vitess.VitessDataSource;
import com.jd.jdbc.vitess.VitessJdbcProperyUtil;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.util.Map;
import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.constructor.Constructor;

public class TableTestUtil {

    public static void setSplitTableConfig(final String path, final String jdbcurl) throws Exception {
        Yaml yaml = new Yaml(new Constructor(SplitTableConfig.class));
        InputStream inputStream = TableTestUtil.class.getClassLoader().getResourceAsStream(path);

        SplitTableConfig splitTableConfig = yaml.load(inputStream);

        Map<String, Map<String, LogicTable>> tableIndexesMap = VitessJdbcProperyUtil.buildTableIndexesMap(splitTableConfig);

        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

        Class clazz = classLoader.loadClass("com.jd.jdbc.vitess.VitessDataSource");
        java.lang.reflect.Constructor constructor = clazz.getConstructor(String.class);
        VitessDataSource obj = (VitessDataSource) constructor.newInstance(jdbcurl);
        Method method = clazz.getDeclaredMethod("setTableIndexesMap", Map.class);
        method.setAccessible(true);
        method.invoke(obj, tableIndexesMap);
        Executor executor = Executor.getInstance(300);
        executor.getPlans().clear();
    }

}
